import QtQuick
import Quickshell
import Quickshell.Wayland
import "bars"
import "widgets/rightBarWidgets"
import "widgets/centerBarWidgets/console"     

ShellRoot {

    PanelWindow { 
        id: rightBarWindow
        anchors { top: true; right: true }
        implicitWidth:  Tokens.rightWidth
        implicitHeight: Tokens.rightHeight 
        color: "transparent"
        exclusiveZone: Tokens.exclusiveZone
        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.namespace: "doomshell-right"

        RightBar { anchors.fill: parent }
    }
 
    PanelWindow {
        id: dropdownWindow
        anchors { top: true; right: true }
        implicitWidth:  sysPanel.implicitWidth
        implicitHeight: Globals.activePanel !== "" ? sysPanel.implicitHeight : 0
        
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
            border.width: Tokens.strokeWidth
        }

        SystemPanel {
            id: sysPanel
        }
    }
        
    PanelWindow {
        id: leftBarWindow
        anchors { top: true; left: true }
        implicitWidth:  Tokens.leftWidth
        implicitHeight: Tokens.leftHeight
        color: "transparent"
        exclusiveZone: Tokens.exclusiveZone
        WlrLayershell.layer:     WlrLayer.Top
        WlrLayershell.namespace: "doomshell-left"

        LeftBar { anchors.fill: parent }
    }

    PanelWindow {
        id: centerBarWindow
        anchors { top: true }
        implicitWidth:  Tokens.centerWidth
        implicitHeight: Tokens.centerHeight
        color: "transparent"
        exclusiveZone: Tokens.exclusiveZone
        WlrLayershell.layer:     WlrLayer.Top
        WlrLayershell.namespace: "doomshell-center"

        CenterBar { anchors.fill: parent }
    }

    PanelWindow {
        id: consoleDropdownWindow
        anchors { top: true }
        implicitWidth:  Tokens.centerWidth - 2 * Tokens.centerHeight
        implicitHeight: !Globals.activeCenterPanel ? 0 : Tokens.centerWidth * 3 / 4

        Behavior on implicitHeight {
            NumberAnimation { duration: 50; easing.type: Easing.OutQuart }
        }
        
        color:         "transparent"
        exclusiveZone: 0
        WlrLayershell.layer:         WlrLayer.Top
        WlrLayershell.namespace:     "doomshell-console-dropdown"
        WlrLayershell.margins.top:   5
        WlrLayershell.margins.right: 5
        visible: Globals.activeCenterPanel

        Console {
            anchors.fill: parent 
        }
    }
}
