import Quickshell
import Quickshell.Io
import QtQuick
import "../../../.."

Item{
    id: ramStatLoader
    property double __ram_in_use__
    property double __ram_total__

    Timer{
        id: ramTimer
        interval: 1000
        running: true
        repeat: true
        onTriggered: ramProc.running = true
    }

    Process{
        id: ramProc
        command:[
            "cat",
            "/proc/meminfo"
        ]

    stdout: StdioCollector{
        onStreamFinished: {
                let data = text.trim().split("\n")

                let memTotalInfo = data.find(
                    line => line.startsWith("MemTotal")
                    ).trim().match(/^MemTotal:\s*([\d]+)\s*kB/i)

                let memTotal = parseInt(memTotalInfo[1])
                
                __ram_total__ = parseFloat(memTotal / 10**6).toFixed(2)
                
                let memAvailableInfo = data.find(
                    line => line.startsWith("MemAvailable")
                    ).trim().match(/^MemAvailable:\s*([\d]+)\s*kB/i)

                let memAvailable = parseInt(memAvailableInfo[1])
                
                let memUsed = memTotal - memAvailable
                
                __ram_in_use__ = parseFloat(memUsed / 10**6).toFixed(2)
            }
        }
    }
}