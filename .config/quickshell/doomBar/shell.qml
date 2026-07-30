import QtQuick
import Quickshell
import Quickshell.Wayland
import "bars"
import "edges/rightEdge"
import "widgets/rightBarWidgets"
import "widgets/centerBarWidgets"
import "bottom"

ShellRoot {
    id: shellRoot

    // Shared geometry for placing dropdowns flush under their bar sections
    readonly property int barHeight: barWindow.implicitHeight
    readonly property int dropdownTopGap: Tokens.spacingXs
    readonly property int dropdownTopMargin: barHeight + dropdownTopGap
    readonly property int screenW: Tokens.screenWidth

    // Center a panel of width `panelW` under a bar section at (sectionX, sectionW).
    // sectionX is bar-local (same as screen-x since the bar is full-width).
    // Clamped so the panel never leaves the screen.
    function dropdownLeft(sectionX, sectionW, panelW) {
        const ideal = Math.round(sectionX + sectionW / 2 - panelW / 2)
        const maxLeft = Math.max(0, shellRoot.screenW - panelW - Tokens.spacingXs)
        return Math.max(Tokens.spacingXs, Math.min(ideal, maxLeft))
    }

    PanelWindow {
        id: barWindow
        anchors { top: true; left: true; right: true }
        // Full-width strip; height matches the tallest former section bar
        implicitHeight: Math.max(Tokens.leftHeight, Tokens.rightHeight, Tokens.centerHeight)
        color: "transparent"
        exclusiveZone: Tokens.exclusiveZone
        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.namespace: "doomshell-bar"

        Bar {
            id: topBar
            anchors.fill: parent
        }
    }

    // System telemetry dropdown --- centered under the right bar section
    PanelWindow {
        id: dropdownWindow
        anchors { top: true; left: true }
        implicitWidth:  sysPanel.implicitWidth
        implicitHeight: Globals.activePanel !== "" ? sysPanel.implicitHeight : 0

        Behavior on implicitHeight {
            NumberAnimation { duration: Tokens.animInstant; easing.type: Easing.OutQuart }
        }

        color:         "transparent"
        exclusiveZone: 0
        // Keyboard for CPU core list / RAM process list / GPU actions
        focusable: Globals.activePanel !== ""
        WlrLayershell.layer:     WlrLayer.Top
        WlrLayershell.namespace: "doomshell-dropdown"
        margins.top:  shellRoot.dropdownTopMargin
        margins.left: shellRoot.dropdownLeft(
            topBar.rightSectionX,
            topBar.rightSectionW,
            sysPanel.implicitWidth
        )
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

    // Center dashboard/console/media dropdown --- centered under the center bar section
    PanelWindow {
        id: centerDropdownWindow
        anchors { top: true; left: true }
        implicitWidth:  centerPanel.implicitWidth
        implicitHeight: Globals.activeCenterPanel !== "" ? centerPanel.implicitHeight : 0

        Behavior on implicitHeight {
            NumberAnimation { duration: Tokens.animInstant; easing.type: Easing.OutQuart }
        }

        color:         "transparent"
        exclusiveZone: 0
        // Keyboard for notes / todo fields on dashboard
        focusable: Globals.activeCenterPanel !== ""
        WlrLayershell.layer:     WlrLayer.Top
        WlrLayershell.namespace: "doomshell-center-dropdown"
        margins.top:  shellRoot.dropdownTopMargin
        margins.left: shellRoot.dropdownLeft(
            topBar.centerSectionX,
            topBar.centerSectionW,
            centerPanel.implicitWidth
        )
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
