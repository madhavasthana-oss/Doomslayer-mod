// BluetoothFrontend.qml --- device list + power/scan (T.S.S content)
import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Bluetooth
import "../../.."
import "."

Item {
    id: root
    implicitWidth:  Tokens.edgeWidgetWidth - 2 * Tokens.paddingH
    implicitHeight: Tokens.edgeWidgetHeight * 0.62

    BluetoothBackend { id: backend }

    ColumnLayout {
        anchors.fill: parent
        spacing: Tokens.spacingXs

        RowLayout {
            Layout.fillWidth: true
            spacing: Tokens.spacingXs

            Text {
                text: "BLUETOOTH"
                font.family: Theme.fontDisplay
                font.pixelSize: Tokens.fontSizeLabel
                color: Theme.accent
            }

            Item { Layout.fillWidth: true }

            Rectangle {
                Layout.preferredHeight: Tokens.listRowHeight
                Layout.preferredWidth: pwrLabel.implicitWidth + 2 * Tokens.paddingH
                radius: Tokens.radiusSm
                color: backend.powered ? Theme.bgElevated : Theme.bgSurface
                border.color: backend.powered ? Theme.borderActive : Theme.borderIdle
                border.width: Tokens.strokeWidth
                Text {
                    id: pwrLabel
                    anchors.centerIn: parent
                    text: backend.powered ? "ON" : "OFF"
                    font.family: Theme.fontDisplay
                    font.pixelSize: Tokens.fontSizeLabel
                    color: backend.powered ? Theme.accent : Theme.textDim
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: backend.setPowered(!backend.powered)
                }
            }

            Rectangle {
                Layout.preferredHeight: Tokens.listRowHeight
                Layout.preferredWidth: Tokens.listRowHeight + Tokens.paddingH
                radius: Tokens.radiusSm
                color: backend.discovering ? Theme.bgElevated : Theme.bgSurface
                border.color: backend.discovering ? Theme.borderActive : Theme.borderIdle
                border.width: Tokens.strokeWidth
                Image {
                    id: scanGlyph
                    anchors.centerIn: parent
                    width: Tokens.iconSizeMedium
                    height: Tokens.iconSizeMedium
                    source: Theme.iconRefresh
                    sourceSize: Qt.size(width, height)
                    visible: false
                }
                ColorOverlay {
                    anchors.fill: scanGlyph
                    source: scanGlyph
                    color: backend.discovering ? Theme.accent : Theme.textMuted
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: backend.toggleDiscover()
                }
            }
        }

        Text {
            Layout.fillWidth: true
            text: backend.statusMsg.length ? backend.statusMsg
                : (backend.powered ? "ADAPTER READY" : "ADAPTER OFFLINE")
            font.family: Theme.fontMono
            font.pixelSize: Tokens.fontSizeTiny
            color: Theme.textSecondary
            elide: Text.ElideRight
        }

        ListView {
            id: list
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: Tokens.spacingXss
            model: Bluetooth.devices

            delegate: Rectangle {
                required property var modelData
                width: list.width
                height: Tokens.statBoxHeight
                radius: Tokens.radiusSm
                color: rowMouse.containsMouse ? Theme.bgElevated : Theme.bgSurface
                border.color: modelData.connected ? Theme.borderActive : Theme.borderIdle
                border.width: Tokens.strokeWidth

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: Tokens.paddingH
                    spacing: Tokens.spacingXs

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 0
                        Text {
                            Layout.fillWidth: true
                            text: modelData.name || modelData.deviceName || modelData.address
                            font.family: Theme.fontDisplay
                            font.pixelSize: Tokens.fontSizeLabel
                            color: modelData.connected ? Theme.accent : Theme.textPrimary
                            elide: Text.ElideRight
                        }
                        Text {
                            Layout.fillWidth: true
                            text: {
                                let bits = []
                                if (modelData.connected) bits.push("LINKED")
                                else if (modelData.pairing) bits.push("PAIRING")
                                else if (modelData.paired || modelData.bonded) bits.push("PAIRED")
                                else bits.push("NEW")
                                if (modelData.batteryAvailable)
                                    bits.push(Math.round(modelData.battery * 100) + "%")
                                bits.push(modelData.address)
                                return bits.join("  *  ")
                            }
                            font.family: Theme.fontMono
                            font.pixelSize: Tokens.fontSizeTiny
                            color: Theme.textDim
                            elide: Text.ElideRight
                        }
                    }
                }

                MouseArea {
                    id: rowMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    onClicked: (mouse) => {
                        if (mouse.button === Qt.RightButton) {
                            backend.forgetDevice(modelData)
                            return
                        }
                        if (modelData.connected)
                            backend.disconnectDevice(modelData)
                        else
                            backend.connectDevice(modelData)
                    }
                }
            }

            Text {
                anchors.centerIn: parent
                visible: list.count === 0
                text: backend.powered ? "NO DEVICES" : "POWER ON ADAPTER"
                font.family: Theme.fontDisplay
                font.pixelSize: Tokens.fontSizeLabel
                color: Theme.textDim
            }
        }

        Text {
            Layout.fillWidth: true
            text: "LMB connect * RMB forget"
            font.family: Theme.fontMono
            font.pixelSize: Tokens.fontSizeTiny
            color: Theme.textDim
            horizontalAlignment: Text.AlignHCenter
        }
    }

    Component.onCompleted: {
        if (backend.powered)
            backend.setDiscovering(true)
    }
}
