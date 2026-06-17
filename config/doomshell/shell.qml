import QtQuick
import Quickshell
import Quickshell.Wayland
import "utils"
import "bars"
import "."

ShellRoot {

    PanelWindow {
        id: rightBarWindow
        anchors { 
            top: true; 
            right: true 
        }
        implicitWidth:  Globals.rightWidth
        implicitHeight: Globals.rightHeight
        color: "transparent"
        exclusiveZone: Globals.exclusiveZone    // ← match center
        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.namespace: "doomshell-right"

        RightBar {
            anchors.fill: parent
        }
    }

    PanelWindow {
    id: leftBarWindow
    anchors { 
        top: true; 
        left: true 
    }
    implicitWidth:  Globals.leftWidth
    implicitHeight: Globals.leftHeight
    color: "transparent"
    exclusiveZone: Globals.exclusiveZone    // ← match center
    WlrLayershell.layer:     WlrLayer.Top
    WlrLayershell.namespace: "doomshell-left"

    LeftBar {
        anchors.fill: parent
    }
}

    PanelWindow {
        id: centerBarWindow
        anchors { top: true }
        implicitWidth:  Globals.centerWidth
        implicitHeight: Globals.centerHeight
        color: "transparent"
        exclusiveZone: Globals.exclusiveZone
        WlrLayershell.layer:     WlrLayer.Top
        WlrLayershell.namespace: "doomshell-center"

        CenterBar {
            anchors.fill: parent
        }
    }

}