import Quickshell
import Quickshell.Io
import QtQuick
import "../../../.."
Item {
    id: ramBackend

    property int     __num_proc__ : 10
    property double __ram_in_use__: -1.00
    property double __ram_total__ : -1.00

    ListModel {
        id: procData
    }

    property alias processes: procData
    property bool __is_ready__: false

    Timer {
        id: ramTimer
        interval: 1000
        running: true
        repeat: true
        onTriggered: ramProc.running = true
    }

    Timer {
        id: topProcTimer
        interval: 2000
        running: true
        repeat: true
        onTriggered: {
            console.log("timer fired, proc count:", procData.count)
            topProcProc.running = true
        }
    }

    Process {
        id: ramProc
        command: [
            "cat",
            "/proc/meminfo"
        ]
        stdout: StdioCollector {
            onStreamFinished: {
                let data = text.trim().split("\n")
                let memTotalInfo = data.find(
                    line => line.startsWith("MemTotal")
                ).trim().match(/^MemTotal:\s*([\d]+)\s*kB/i)
                let memTotal = parseInt(memTotalInfo[1])
                __ram_total__ = parseFloat(memTotal / 1024**2).toFixed(2)
                if (!ramBackend.__is_ready__) {
                    ramBackend.__is_ready__ = true
                }
                let memAvailableInfo = data.find(
                    line => line.startsWith("MemAvailable")
                ).trim().match(/^MemAvailable:\s*([\d]+)\s*kB/i)
                let memAvailable = parseInt(memAvailableInfo[1])
                let memUsed = memTotal - memAvailable
                __ram_in_use__ = parseFloat(memUsed / 10**6).toFixed(2)
            }
        }
    }

    Process {
        id: topProcProc
        command: [
            "ps",
            "--no-headers",
            "-axo",
            "pid,comm,rss,etimes",
            "--sort=-rss"
        ]
        stdout: StdioCollector {
            onStreamFinished: {
                let lines = text.trim().split("\n").slice(0, __num_proc__)
                for (let idx = 0; idx < __num_proc__; idx++) {
                console.log("stream finished, lines:", text.trim().split("\n").length)
                    let fields = lines[idx].trim().split(/\s+/)
                    let pid    = parseInt(fields[0])
                    let name   = fields[1]
                    let rssKb  = parseInt(fields[2])
                    let upSecs = parseInt(fields[3])
                    let entry = {
                        idx:    idx,
                        pid:    pid,
                        name:   name,
                        ram_mb: parseFloat(rssKb / 1024).toFixed(2),
                        uptime: formatUptime(upSecs)
                    }
                    if (idx < procData.count) {
                        procData.set(idx, entry)
                    } else {
                        procData.append(entry)
                    }
                }
            }
        }
    }

    function formatUptime(totalSeconds) {
        let hours   = Math.floor(totalSeconds / 3600)
        let minutes = Math.floor((totalSeconds % 3600) / 60)
        if (hours > 0) {
            return hours + "h " + minutes + "m"
        }
        return minutes + "m"
    }
}