import QtQuick
import Quickshell
import Quickshell.Wayland
import "bars"
import "widgets/rightBarWidgets"
import "widgets/centerBarWidgets"
import "bottom"

ShellRoot {
    id:shellRoot
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
        id: centerDropdownWindow
        anchors { top: true }
        implicitWidth:  centerPanel.implicitWidth
        implicitHeight: Globals.activeCenterPanel !== "" ? centerPanel.implicitHeight : 0

        Behavior on implicitHeight {
            NumberAnimation { duration: 50; easing.type: Easing.OutQuart }
        }
        
        color:         "transparent"
        exclusiveZone: 0
        WlrLayershell.layer:         WlrLayer.Top
        WlrLayershell.namespace:     "doomshell-center-dropdown"
        WlrLayershell.margins.top:   5
        visible: Globals.activeCenterPanel !== ""

        Rectangle {
            id: centerPanelBg
            anchors.fill: parent
            radius:       10
            color:        Theme.bgConsole
            opacity:      Theme.opacityConsole
            border.color: Theme.borderConsole
            border.width: Tokens.strokeWidth
        }

        CenterPanel {
            id: centerPanel
        }
    }

    // Bottom power bar — dormant hotzone at bottom-center, expands on hover.
    // Height follows sticky `revealed` (grace-period close) so edge hover
    // doesn't thrash open/closed while the window resizes under the cursor.
    PanelWindow {
        id: bottomBarWindow
        anchors {
            left:   true
            right:  true
            bottom: true
        }
        margins.left:  Tokens.bottomBarOriginX
        margins.right: Tokens.bottomBarOriginX

        implicitWidth: Tokens.bottomBarWidth
        // Height snaps with sticky revealed state (no Behavior) — animating
        // the layer-shell window under the cursor was the thrash source.
        implicitHeight: bottomPanel.revealed
            ? Tokens.bottomBarHeight
            : Tokens.bottomHoverZoneHeight

        color:         "transparent"
        exclusiveZone: 0
        WlrLayershell.layer:     WlrLayer.Top
        WlrLayershell.namespace: "doomshell-bottom"

        BottomPanel {
            id: bottomPanel
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            width:  Tokens.bottomBarWidth
            height: Tokens.bottomBarHeight
            opacity: bottomPanel.revealed
                ? Theme.opacityVisible
                : Theme.opacityHidden

            Behavior on opacity {
                NumberAnimation {
                    duration: Tokens.animFast
                    easing.type: Easing.OutCubic
                }
            }
        }
    }
}
