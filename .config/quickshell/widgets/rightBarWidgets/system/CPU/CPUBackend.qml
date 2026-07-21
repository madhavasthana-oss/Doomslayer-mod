import Quickshell
import QtQuick
import Quickshell.Io
import "../../../.."

Item {
    id: cpuBackend

    property bool coreInitialized: false
    property bool ready           : false
    property int  coreCount      : -1
    property int  historyLength       : 20
    property int  intervalLength      : 500

    // WARNING --- THIS IS HARDCODED!! YOU NEED TO UPDATE THIS YOURSELF FOR ACCURATE READING
    property var coreIdMap: [0, 0, 4, 4, 8, 9, 10, 11, 12, 13, 14, 15]

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

    Timer {
        id: detector
        interval: parent.intervalLength
        running:  true
        repeat:   true
        onTriggered: {
            if (cpuBackend.coreCount === -1 && !cpuBackend.coreInitialized) {
                cpuBackend.coreInitialized = true
                coreInitializer.running = true
            } else if (cpuBackend.coreCount !== -1) {
                cpuProc.running = true
            }
        }
    }

    Process {
        id: coreInitializer
        command: ["nproc", "--all"]
        stdout: StdioCollector {
            onStreamFinished: {
                if (cpuBackend.coreCount === -1) {
                    let count = parseInt(text.trim())
                    cpuBackend.coreCount = count

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
                if (cpuBackend.coreCount === -1) return;

                let lines = text.trim().split("\n")

                for (let core = 0; core < cpuBackend.coreCount; core++) {
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

                if (!cpuBackend.ready) {
                    cpuBackend.ready = true
                }
            }
        }
    }

    Timer {
        id: tempDetector
        interval: parent.intervalLength
        running:  false
        repeat:   true
        onTriggered: tempProc.running = true
    }

    Process {
        id: tempProc
        command: ["sensors", "-j", "coretemp-isa-0000"]
        stdout: StdioCollector {
            onStreamFinished: {
                if (cpuBackend.coreCount === -1) return;

                let parsed;
                try {
                    parsed = JSON.parse(text)
                } catch (e) {
                    return;
                }

                let coretemp = parsed["coretemp-isa-0000"]
                if (!coretemp) return;

                for (let core = 0; core < cpuBackend.coreCount; core++) {
                    let sensorLabel = "Core " + cpuBackend.coreIdMap[core]
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