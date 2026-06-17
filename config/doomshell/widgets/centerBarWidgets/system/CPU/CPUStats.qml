import Quickshell
import Quickshell.Io
import QtQuick
import "../../../.."

/*
solve the problem of appearing zeroes in all workspaces with the following plan
1. one process to determine if the value has changed or not over a time, the timer
    runs repeatedly UNITL a change in the value is detected

2. the moment the value changes, the timer is set to stop and all operations carry on

*/ 

Item {
    id: cpuStatsWindow
    property int __cpu_usage__ : -1
    property int __last_cpu_idle__ : -1 
    property int __last_cpu_total__ : -1 
    property bool __is_ready__ : false
    signal ready

    Timer{
        id: detector
        interval: 1000
        running: true
        repeat:  true
        onTriggered: cpuProc.running = true
    }
    Process {
        id: cpuProc
        command: [
            "cat",
            "/proc/stat"
        ]
        stdout: StdioCollector{
            onStreamFinished: {
                // accesses a line whenever text it split by a new entry, and take the first entry, cause that returns the cpu
                let line   = text.split("\n")[0]
                // split the line obtained with uniform spaces 
                let fields = line.trim().split(/\s+/)

                let user    = Number(fields[1])
                let nice    = Number(fields[2])
                let system  = Number(fields[3])
                let idle    = Number(fields[4])
                let iowait  = Number(fields[5])
                let irq     = Number(fields[6])
                let softirq = Number(fields[7])
                let total = 0
                for (let idx = 1; idx < fields.length; idx++) {
                    total += Number(fields[idx])
                }

                // calculate delta using OLD baseline
                if (cpuStatsWindow.__last_cpu_total__ != 0) {
                    let totalDelta = total - cpuStatsWindow.__last_cpu_total__
                    let idleDelta  = idle  - cpuStatsWindow.__last_cpu_idle__
                    cpuStatsWindow.__cpu_usage__ = Math.round(
                        ((totalDelta - idleDelta) / totalDelta) * 100
                    )

                    // fire ready() only once — on first valid delta
                    if (!cpuStatsWindow.__is_ready__) {
                        cpuStatsWindow.__is_ready__ = true
                        cpuStatsWindow.ready()
                    }
                }

                // store NEW baseline AFTER calculation
                cpuStatsWindow.__last_cpu_total__ = total
                cpuStatsWindow.__last_cpu_idle__  = idle
            }
        }
    }
}       