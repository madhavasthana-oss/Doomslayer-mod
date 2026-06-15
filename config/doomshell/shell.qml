import QtQuick
import Quickshell
import Quickshell.Wayland
import "utils"

ShellRoot {

    PanelWindow {
        id: leftBarWindow
        anchors { top: true; left: true }
        implicitWidth:  340
        implicitHeight: 20
        color: "transparent"
        exclusiveZone: 0
        WlrLayershell.layer:     WlrLayer.Top
        WlrLayershell.namespace: "doomshell-left"

        LeftTrapezoid {
            anchors.fill: parent
            barWidth:     340
            barHeight:    20
            alertActive:  false
        }
    }

    PanelWindow {
        id: centerBarWindow
        anchors { top: true }
        implicitWidth:  640
        implicitHeight: 30
        color: "transparent"
        exclusiveZone: 0
        WlrLayershell.layer:     WlrLayer.Top
        WlrLayershell.namespace: "doomshell-center"

        CenterTrapezoid {
            anchors.fill: parent
            barWidth:     640
            barHeight:    30
            alertActive:  false
        }
    }

     PanelWindow {
         id: rightBarWindow
         anchors { top: true; right: true }
         implicitWidth:  340
         implicitHeight: 20
         color: "transparent"
         exclusiveZone: 0
         WlrLayershell.layer:     WlrLayer.Top
         WlrLayershell.namespace: "doomshell-right"

         RightTrapezoid {
             anchors.fill: parent
             barWidth:     340
             barHeight:    20
             alertActive:  false
         }
     }
}
