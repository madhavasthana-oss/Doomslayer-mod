import Quickshell
import Quickshell.Io
import QtQuick
import "../../../.."

Item{
    id: tempStatsWindow
    property double __temp__
    property bool __is_ready__: false

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
                if(!tempStatsWindow.__is_ready__){
                    tempStatsWindow.__is_ready__ = true
                }
            }
        }
    }

}

