import QtQuick
import Quickshell
import Quickshell.Wayland
import QtQuick.Layouts
import "utils"
import "bars"
import "."
import "widgets/rightBarWidgets"
import "edges"
import "widgets/rightBarWidgets/system/CPU"
import "widgets/rightBarWidgets/system/GPU"
import "widgets/rightBarWidgets/system/RAM"
import "widgets/centerBarWidgets/console"     

ShellRoot {

    PanelWindow {
        id: rightBarWindow
        anchors { top: true; right: true }
        implicitWidth:  Globals.rightWidth
        implicitHeight: Globals.rightHeight 
        color: "transparent"
        exclusiveZone: Globals.exclusiveZone
        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.namespace: "doomshell-right"

        RightBar { anchors.fill: parent }
    }
    

    PanelWindow {
        id: dropdownWindow
        anchors { top: true; right: true }
        implicitWidth:  Globals.rightWidth
        implicitHeight: Globals.activePanel !== "" ? Globals.rightWidth * 43 / 35 : 0

        Behavior on implicitHeight {
            NumberAnimation { duration: 50; easing.type: Easing.OutQuart }
        }

        color:         "transparent"
        exclusiveZone: 0
        WlrLayershell.layer:         WlrLayer.Top
        WlrLayershell.namespace:     "doomshell-dropdown"
        WlrLayershell.margins.top:   0
        WlrLayershell.margins.right: 5
        visible: Globals.activePanel !== ""

         Rectangle {
            id: panelBg
            anchors.fill: parent
            radius:       10
            color:        Theme.bgConsole
            opacity:      Theme.opacityConsole
            border.color: Theme.borderConsole
            border.width: Theme.strokeWidth
        }

        SystemPanel {
            anchors.fill: parent
        }
    }
        

    PanelWindow {
        id: leftBarWindow
        anchors { top: true; left: true }
        implicitWidth:  Globals.leftWidth
        implicitHeight: Globals.leftHeight
        color: "transparent"
        exclusiveZone: Globals.exclusiveZone
        WlrLayershell.layer:     WlrLayer.Top
        WlrLayershell.namespace: "doomshell-left"

        LeftBar { anchors.fill: parent }
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

        CenterBar { anchors.fill: parent }
    }

    PanelWindow {
        id: consoleDropdownWindow
        anchors { top: true }
        implicitWidth:  Globals.centerWidth - 2 * Globals.centerHeight
        implicitHeight: !Globals.consolePanelOpen ? 0 : Globals.centerWidth * 3 / 4

        Behavior on implicitHeight {
            NumberAnimation { duration: 50; easing.type: Easing.OutQuart }
        }

        color:         "transparent"
        exclusiveZone: 0
        WlrLayershell.layer:         WlrLayer.Top
        WlrLayershell.namespace:     "doomshell-console-dropdown"
        WlrLayershell.margins.top:   5
        WlrLayershell.margins.right: 5
        visible: Globals.consolePanelOpen

        Console {
            anchors.fill: parent 
        }
    }

}
