import Quickshell
import Quickshell.Io
import QtQuick
import "../../../.."

Item{
    id: tempStatsWindow
    property double temp
    property bool isReady: false

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
                temp = parseFloat(parseInt(text, 10) / 1000)
                if(!tempStatsWindow.isReady){
                    tempStatsWindow.isReady = true
                }
            }
        }
    }

}

