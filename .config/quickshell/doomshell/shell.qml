import QtQuick
import Quickshell
import Quickshell.Wayland
import "bars"
import "edges/rightEdge"
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
            NumberAnimation { duration: Tokens.animInstant; easing.type: Easing.OutQuart }
        }

        color:         "transparent"
        exclusiveZone: 0
        // Keyboard for CPU core list / RAM process list / GPU actions
        focusable: Globals.activePanel !== ""
        WlrLayershell.layer:         WlrLayer.Top
        WlrLayershell.namespace:     "doomshell-dropdown"
        WlrLayershell.margins.top:   0
        WlrLayershell.margins.right: Tokens.spacingXs
        visible: Globals.activePanel !== ""

         Rectangle {
            id: panelBg
            anchors.fill: parent
            radius:       Tokens.radiusXl
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
            NumberAnimation { duration: Tokens.animInstant; easing.type: Easing.OutQuart }
        }
        
        color:         "transparent"
        exclusiveZone: 0
        // Keyboard for notes / todo fields on dashboard
        focusable: Globals.activeCenterPanel !== ""
        WlrLayershell.layer:         WlrLayer.Top
        WlrLayershell.namespace:     "doomshell-center-dropdown"
        WlrLayershell.margins.top:   Tokens.spacingXs
        visible: Globals.activeCenterPanel !== ""

        Rectangle {
            id: centerPanelBg
            anchors.fill: parent
            radius:       Tokens.radiusXl
            color:        Theme.bgConsole
            opacity:      Theme.opacityConsole
            border.color: Theme.borderConsole
            border.width: Tokens.strokeWidth
        }

        CenterPanel {
            id: centerPanel
        }
    }

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

    PanelWindow {
        id: rightEdgeWidget
        anchors.right: true
        margins.top:   Tokens.edgeWidgetOriginY

        implicitWidth: rightEdgePanel.revealed
            ? Tokens.edgeWindowWidth
            : Tokens.edgeHoverZoneCollapsed
        implicitHeight: Tokens.edgeWindowHeight

        // Keyboard focus for wifi password field
        focusable: rightEdgePanel.revealed

        color:         "transparent"
        exclusiveZone: 0
        WlrLayershell.layer:     WlrLayer.Top
        WlrLayershell.namespace: "doomshell-right-edge"

        RightEdgePanel {
            id: rightEdgePanel
            anchors.fill: parent
            opacity: rightEdgePanel.revealed
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
