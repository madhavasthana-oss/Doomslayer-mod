import Quickshell
import Quickshell.Io
import QtQuick
import "../../../.."

Item{
    id: gpuStatsWindow
    property int __gpu_usage__ : 0
    property int __last_gpu_idle__ : 0
    property int __last_gpu_total__ : 0
    
    Timer {
        interval: 1000
        running : true
        repeat  : true

        onTriggered: gpuProc.running = true
    }

    Process {
        id: gpuProc
        command :[
            "turbostat", 
            "--Summary",
            "--quiet", 
            "--show", 
            "GFX%rc6,GFXMHz", 
            "--no-msr", 
            "--no-perf",
            "-n",
             "1"
        ]

        stdout: StdioCollector{
            onStreamFinished:{
                let lines = text.trim().split("\n")
                let data = lines[1].trim().split(/\s+/)
                let rc6 = parseFloat(data[0])
                let freq = parseInt(data[1])

                __gpu_usage__ = 100 - rc6
            }
        }
    }
}