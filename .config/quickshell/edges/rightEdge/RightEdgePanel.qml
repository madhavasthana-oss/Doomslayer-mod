// RightEdgePanel.qml
import QtQuick
import QtQuick.Layouts
import ".."
import Quickshell
import Quickshell.Wayland

Item {
    id: root

    // ─── Size & Position Settings ─────────────────────
    property int panelWidth:  280
    property int panelHeight: 420
    property int edgeMargin:  5

    // Hover detection zone (thin strip on the right edge)
    MouseArea {
        id: hoverTrigger
        anchors.right: parent.right
        width: 40          // how wide the hover zone is
        height: panelHeight
        hoverEnabled: true
        onEntered: powerPanel.state = "visible"
        onExited:  powerPanel.state = "hidden"
    }
 
    // The actual sliding panel
    Rectangle {
        id: powerPanel

        width:  panelWidth
        height: panelHeight
        radius: 12
        color:  Theme.bgConsole
        opacity: Theme.opacityConsole
        border.color: Theme.borderConsole
        border.width: Theme.strokeWidth

        // Position: center of right edge with margin
        anchors.right: parent.right
        anchors.rightMargin: edgeMargin
        anchors.verticalCenter: parent.verticalCenter

        // Animation state
        state: "hidden"
        states: [
            State {
                name: "hidden"
                PropertyChanges { target: powerPanel; x: parent.width + 20 }   // off-screen
            },
            State {
                name: "visible"
                PropertyChanges { target: powerPanel; x: parent.width - panelWidth - edgeMargin }
            }
        ]

        transitions: Transition {
            NumberAnimation {
                properties: "x"
                duration: 220
                easing.type: Easing.OutCubic
            }
        }

        // ─── Power Controls Content ─────────────────────
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 16

            Text {
                text: "POWER"
                font.family: Theme.fontDisplay
                font.pixelSize: Theme.fontSizeLarge
                color: Theme.accent
            }

            // Power menu button
            Rectangle {
                Layout.fillWidth: true
                height: 48
                radius: 8
                color: powerMouse.containsMouse ? Theme.stateCritical : Theme.bgSurface
                border.color: Theme.borderIdle

                Text {
                    anchors.centerIn: parent
                    text: "Power Menu"
                    font.family: Theme.fontDisplay
                    color: powerMouse.containsMouse ? Theme.accent : Theme.textMuted
                }

                MouseArea {
                    id: powerMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        // Example: launch your power script
                        Quickshell.execDetached(["bash", "-c", "~/.config/doomshell/scripts/bash/power-menu.sh"])
                    }
                }
            }

            Item { Layout.fillHeight: true } // spacer
        }
    }
}