import Quickshell
import QtQuick
import Quickshell.Io
import "../../../.."

Item {
    id: cpuBackend

    property bool __core_initialized__: false
    property bool __ready__           : false
    property int  __core_count__      : -1
    property int  historyLength       : 20

    // WARNING --- THIS IS HARDCODED!! YOU NEED TO UPDATE THIS YOURSELF FOR ACCURATE READING
    property var __core_id_map__: [0, 0, 4, 4, 8, 9, 10, 11, 12, 13, 14, 15]

    // Plain JS store — keyed by core index
    // history[i] = { usage: [...], temp: [...] }
    property var history: ({})

    ListModel {
        id: coreData
    }
    property alias cores: coreData

    function setCore(idx, idle, total, usage) {
        coreData.setProperty(idx, "idle",  idle)
        coreData.setProperty(idx, "total", total)
        coreData.setProperty(idx, "usage", usage)
    }

    function setTemp(idx, temp) {
        coreData.setProperty(idx, "temp", temp)
    }

    function initHistory(count) {
        let h = {}
        for (let i = 0; i < count; i++) {
            h[i] = {
                usage: new Array(historyLength).fill(undefined),
                temp:  new Array(historyLength).fill(undefined)
            }
        }
        history = h
    }

    function getEarliestUndefined(buffer) {
        let nextEntry = 1
        for (let i = -1; i >= -historyLength; i--) {
            let val = buffer[buffer.length + i]
            if (val === undefined) {
                nextEntry = i
            } else {
                break
            }
        }
        return nextEntry
    }

    function pushHistory(coreIdx, usage, temp) {
        let h    = history
        let slot = h[coreIdx]
        if (!slot) return

        let uBuf = slot.usage.slice()
        let tBuf = slot.temp.slice()

        let nextEntry = getEarliestUndefined(uBuf)

        if (nextEntry === 1) {
            uBuf = uBuf.slice(1)
            tBuf = tBuf.slice(1)
            uBuf.push(usage)
            tBuf.push(temp)
        } else {
            uBuf[uBuf.length + nextEntry] = usage
            tBuf[tBuf.length + nextEntry] = temp
        }

        h[coreIdx] = { usage: uBuf, temp: tBuf }
        history = h
    }

    // ---------------------------------------------------------
    //  USAGE — polls every 1s via /proc/stat
    // ---------------------------------------------------------

    Timer {
        id: detector
        interval: 150
        running:  true
        repeat:   true
        onTriggered: {
            if (cpuBackend.__core_count__ === -1 && !cpuBackend.__core_initialized__) {
                cpuBackend.__core_initialized__ = true
                coreInitializer.running = true
            } else if (cpuBackend.__core_count__ !== -1) {
                cpuProc.running = true
            }
        }
    }

    Process {
        id: coreInitializer
        command: ["nproc", "--all"]
        stdout: StdioCollector {
            onStreamFinished: {
                if (cpuBackend.__core_count__ === -1) {
                    let count = parseInt(text.trim())
                    cpuBackend.__core_count__ = count

                    for (let i = 0; i < count; i++) {
                        coreData.append({
                            idx:   i,
                            idle:  -1,
                            total: -1,
                            usage: -1,
                            temp:  -1
                        })
                    }

                    cpuBackend.initHistory(count)
                    tempDetector.running = true
                }
            }
        }
    }

    Process {
        id: cpuProc
        command: ["cat", "/proc/stat"]
        stdout: StdioCollector {
            onStreamFinished: {
                if (cpuBackend.__core_count__ === -1) return;

                let lines = text.trim().split("\n")

                for (let core = 0; core < cpuBackend.__core_count__; core++) {
                    let line = lines[core + 1]
                    if (!line) continue

                    let fields = line.trim().split(/\s+/)
                    let idle  = Number(fields[4])
                    let total = 0
                    for (let i = 1; i < fields.length; i++) {
                        total += Number(fields[i])
                    }

                    let row       = coreData.get(core)
                    let prevTotal = row.total
                    let prevIdle  = row.idle
                    let usage     = row.usage

                    if (prevTotal !== -1) {
                        let totalDelta = total - prevTotal
                        let idleDelta  = idle  - prevIdle
                        if (totalDelta > 0) {
                            usage = Math.round(((totalDelta - idleDelta) / totalDelta) * 100)
                        }
                    }

                    cpuBackend.setCore(core, idle, total, usage)

                    if (usage !== -1) {
                        let temp = coreData.get(core).temp
                        cpuBackend.pushHistory(core, usage, temp !== -1 ? temp : undefined)
                    }
                }

                if (!cpuBackend.__ready__) {
                    cpuBackend.__ready__ = true
                }
            }
        }
    }

    // ---------------------------------------------------------
    //  TEMPERATURE — polls every 4s via lm-sensors
    // ---------------------------------------------------------

    Timer {
        id: tempDetector
        interval: 150
        running:  false
        repeat:   true
        onTriggered: tempProc.running = true
    }

    Process {
        id: tempProc
        command: ["sensors", "-j", "coretemp-isa-0000"]
        stdout: StdioCollector {
            onStreamFinished: {
                if (cpuBackend.__core_count__ === -1) return;

                let parsed;
                try {
                    parsed = JSON.parse(text)
                } catch (e) {
                    return;
                }

                let coretemp = parsed["coretemp-isa-0000"]
                if (!coretemp) return;

                for (let core = 0; core < cpuBackend.__core_count__; core++) {
                    let sensorLabel = "Core " + cpuBackend.__core_id_map__[core]
                    let sensorObj   = coretemp[sensorLabel]
                    if (!sensorObj) continue;

                    let tempKey = Object.keys(sensorObj)[0]
                    let temp    = sensorObj[tempKey]

                    cpuBackend.setTemp(core, temp)
                }
            }
        }
    }
}