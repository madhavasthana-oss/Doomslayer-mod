// RightEdgePanel.qml — T.S.S host: tiles → separator → stack
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
            onSwitched: (panel) => {
                Globals.activeEdgePanel = panel
                Globals.lastEdgePanel = panel
            }
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
