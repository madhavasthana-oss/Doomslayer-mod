import QtQuick
import Quickshell
import Quickshell.Wayland
import "utils"
import "bars"
import "."

ShellRoot {

    PanelWindow {
        id: leftBarWindow
        anchors { top: true; left: true }
        implicitWidth:  Globals.leftWidth
        implicitHeight: Globals.leftHeight
        color: "transparent"
        exclusiveZone: 0
        WlrLayershell.layer:     WlrLayer.Top
        WlrLayershell.namespace: "doomshell-left"

        LeftTrapezoid {
            anchors.fill: parent
            barWidth:     Globals.leftWidth
            barHeight:    Globals.leftHeight
            alertActive:  false
        }
    }

    PanelWindow {
        id: centerBarWindow
        anchors { top: true }
        implicitWidth:  Globals.centerWidth
        implicitHeight: Globals.centerHeight
        color: "transparent"
        exclusiveZone: 0
        WlrLayershell.layer:     WlrLayer.Top
        WlrLayershell.namespace: "doomshell-center"

        CenterBar {
            anchors.fill: parent
        }
    }

    PanelWindow {
        id: rightBarWindow
        anchors { top: true; right: true }
        implicitWidth:  Globals.rightWidth
        implicitHeight: Globals.rightHeight
        color: "transparent"
        exclusiveZone: 0
        WlrLayershell.layer:     WlrLayer.Top
        WlrLayershell.namespace: "doomshell-right"

        RightTrapezoid {
            anchors.fill: parent
            barWidth:     Globals.rightWidth
            barHeight:    Globals.rightHeight
            alertActive:  false
        }
    }
}