import Quickshell
import Quickshell.Io
import QtQuick
import "../../../.."

Item{
    id: tempStatsWindow
    property double __temp__

    Timer{
        interval: 1000
        running: true
        repeat: true

        onTriggered: tempStatsProc.running = true
    }

    Process{
        id: tempStatsProc
        command: [
            "cat",
            "/sys/class/thermal/thermal_zone10/temp"
        ]
        stdout: StdioCollector{
            onStreamFinished: {
                __temp__ = parseFloat(parseInt(text, 10) / 1000)
            }
        }
    }

}

