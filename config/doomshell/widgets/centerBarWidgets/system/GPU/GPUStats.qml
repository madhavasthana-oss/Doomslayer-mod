import Quickshell
import Quickshell.Io
import QtQuick
import "../../../.."

Item {
    id: gpuStatsWindow
    property int  __gpu_usage__:  -1
    property bool __is_ready__:   false

    Timer {
        id: detector
        interval: 500
        running:  true
        repeat:   true
        onTriggered: gpuProc.running = true
    }

    Process {
        id: gpuProc
        command: [
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
        stdout: StdioCollector {
            onStreamFinished: {
                let lines = text.trim().split("\n")
                let data  = lines[1].trim().split(/\s+/)
                let rc6   = parseFloat(data[0])

                gpuStatsWindow.__gpu_usage__ = Math.round(100 - rc6)

                if (!gpuStatsWindow.__is_ready__) {
                    gpuStatsWindow.__is_ready__ = true
                }
            }
        }
    }
}