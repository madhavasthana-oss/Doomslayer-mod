// RightEdgePanel.qml --- T.S.S host: tiles -> separator -> stack
import QtQuick
import QtQuick.Layouts
import Quickshell
import "../.."
import "network"
import "bluetooth"
import "settings"
import "notifications"

Item {
    id: root

    implicitWidth:  Tokens.edgeWindowWidth
    implicitHeight: Tokens.edgeWindowHeight

    property bool open: false
    readonly property bool revealed: open

    // Allow children (settings) to force-collapse before launching tools
    function collapse() {
        hideTimer.stop()
        root.open = false
    }

    readonly property var panelOrder: ["wifi", "bluetooth", "settings", "notifications"]

    function switchPanel(panel) {
        Globals.activeEdgePanel = panel
        Globals.lastEdgePanel = panel
        Qt.callLater(root.grabActiveFocus)
    }

    function cyclePanel(delta) {
        const order = root.panelOrder
        let idx = order.indexOf(Globals.activeEdgePanel)
        if (idx < 0)
            idx = 0
        idx = (idx + delta + order.length) % order.length
        switchPanel(order[idx])
    }

    function grabActiveFocus() {
        const panel = Globals.activeEdgePanel
        if (panel === "wifi")
            wifiPage.grabListFocus()
        else if (panel === "bluetooth")
            btPage.grabListFocus()
        else if (panel === "notifications")
            notifPage.grabListFocus()
        else
            root.forceActiveFocus()
    }

    onOpenChanged: {
        if (open)
            Qt.callLater(root.grabActiveFocus)
    }

    focus: true
    Keys.onPressed: (event) => {
        if (event.key === Qt.Key_Left) {
            root.cyclePanel(-1)
            event.accepted = true
        } else if (event.key === Qt.Key_Right) {
            root.cyclePanel(1)
            event.accepted = true
        } else if (event.key === Qt.Key_1) {
            root.switchPanel("wifi")
            event.accepted = true
        } else if (event.key === Qt.Key_2) {
            root.switchPanel("bluetooth")
            event.accepted = true
        } else if (event.key === Qt.Key_3) {
            root.switchPanel("settings")
            event.accepted = true
        } else if (event.key === Qt.Key_4) {
            root.switchPanel("notifications")
            event.accepted = true
        }
    }

    HoverHandler {
        id: hoverHandler
        onHoveredChanged: {
            if (hovered) {
                hideTimer.stop()
                root.open = true
            } else {
                hideTimer.restart()
            }
        }
    }

    Timer {
        id: hideTimer
        interval: Tokens.edgeHideDelay
        repeat: false
        onTriggered: {
            if (!hoverHandler.hovered)
                root.open = false
        }
    }

    Rectangle {
        id: panelBg
        anchors.fill:    parent
        anchors.margins: Tokens.edgePanelPad
        radius:          Tokens.radiusXl
        color: Qt.rgba(
            Theme.bgConsole.r,
            Theme.bgConsole.g,
            Theme.bgConsole.b,
            Theme.opacityConsole
        )
        border.color: Theme.borderActive
        border.width: Math.max(Tokens.borderXss, Math.round(Tokens.strokeWidthActive))
        antialiasing: true
    }

    ColumnLayout {
        id: mainLayout
        anchors.fill:    panelBg
        anchors.margins: Tokens.paddingH
        spacing:         Tokens.spacingSm

        // 1. Tile grid
        EdgeTabs {
            id: tabs
            Layout.fillWidth: true
            active: Globals.activeEdgePanel
            onSwitched: (panel) => root.switchPanel(panel)
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: Tokens.strokeWidth
            color: Theme.borderIdle
            opacity: 0.5
        }

        StackLayout {
            id: stack
            Layout.fillWidth:  true
            Layout.fillHeight: true

            currentIndex: {
                const panels = ["wifi", "bluetooth", "settings", "notifications"]
                const idx = panels.indexOf(Globals.activeEdgePanel)
                return idx < 0 ? 0 : idx
            }

            NetworkFrontend {
                id: wifiPage
            }

            BluetoothFrontend {
                id: btPage
            }

            SettingsFrontend {
                id: settingsPage
                onRequestClose: root.collapse()
            }

            NotifFrontend {
                id: notifPage
            }
        }
    }
}
