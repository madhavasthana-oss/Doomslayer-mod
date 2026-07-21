// NetworkFrontend.qml --- wifi list + password + rescan (T.S.S content)
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import Quickshell
import "../../.."
import "."

Item {
    id: root
    implicitWidth:  Tokens.edgeWidgetWidth - 2 * Tokens.paddingH
    implicitHeight: Tokens.edgeWidgetHeight * 0.62

    NetworkBackend { id: backend }

    ColumnLayout {
        anchors.fill: parent
        spacing: Tokens.spacingXs

        // Header row
        RowLayout {
            Layout.fillWidth: true
            spacing: Tokens.spacingXs

            Text {
                text: "NETWORK"
                font.family: Theme.fontDisplay
                font.pixelSize: Tokens.fontSizeLabel
                color: Theme.accent
            }

            Item { Layout.fillWidth: true }

            Rectangle {
                Layout.preferredHeight: Tokens.listRowHeight
                Layout.preferredWidth: wifiToggleLabel.implicitWidth + 2 * Tokens.paddingH
                radius: Tokens.radiusSm
                color: backend.wifiEnabled ? Theme.bgElevated : Theme.bgSurface
                border.color: backend.wifiEnabled ? Theme.borderActive : Theme.borderIdle
                border.width: Tokens.strokeWidth

                Text {
                    id: wifiToggleLabel
                    anchors.centerIn: parent
                    text: backend.wifiEnabled ? "ON" : "OFF"
                    font.family: Theme.fontDisplay
                    font.pixelSize: Tokens.fontSizeLabel
                    color: backend.wifiEnabled ? Theme.accent : Theme.textDim
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: backend.setWifiEnabled(!backend.wifiEnabled)
                }
            }

            Rectangle {
                Layout.preferredHeight: Tokens.listRowHeight
                Layout.preferredWidth: Tokens.listRowHeight + Tokens.paddingH
                radius: Tokens.radiusSm
                color: rescanMouse.containsMouse ? Theme.bgElevated : Theme.bgSurface
                border.color: Theme.borderIdle
                border.width: Tokens.strokeWidth

                Item {
                    anchors.centerIn: parent
                    width: Tokens.iconSizeMedium
                    height: Tokens.iconSizeMedium

                    Image {
                        id: refreshGlyph
                        anchors.fill: parent
                        source: Theme.iconRefresh
                        sourceSize: Qt.size(width, height)
                        visible: false
                    }
                    ColorOverlay {
                        anchors.fill: refreshGlyph
                        source: refreshGlyph
                        color: backend.scanning ? Theme.accent : Theme.textMuted
                    }

                    RotationAnimator on rotation {
                        running: backend.scanning
                        from: 0; to: 360
                        duration: 800
                        loops: Animation.Infinite
                    }
                }
                MouseArea {
                    id: rescanMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: backend.rescan()
                }
            }
        }

        Text {
            Layout.fillWidth: true
            text: backend.statusMsg
            font.family: Theme.fontMono
            font.pixelSize: Tokens.fontSizeTiny
            color: Theme.textSecondary
            elide: Text.ElideRight
        }

        // Password prompt
        ColumnLayout {
            Layout.fillWidth: true
            spacing: Tokens.spacingXs
            visible: backend.needsPassword

            Text {
                text: "KEY FOR " + backend.pendingSsid
                font.family: Theme.fontDisplay
                font.pixelSize: Tokens.fontSizeLabel
                color: Theme.stateWarning
            }

            TextField {
                id: pskField
                Layout.fillWidth: true
                echoMode: TextInput.Password
                placeholderText: "passphrase"
                color: Theme.textPrimary
                placeholderTextColor: Theme.textDim
                font.family: Theme.fontMono
                font.pixelSize: Tokens.fontSizeSmall
                background: Rectangle {
                    color: Theme.bgSurface
                    radius: Tokens.radiusSm
                    border.color: Theme.borderActive
                    border.width: Tokens.strokeWidth
                }
                onAccepted: backend.connectWithPassword(text)
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Tokens.spacingXs

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: Tokens.actionBtnHeight
                    radius: Tokens.radiusSm
                    color: Theme.bgElevated
                    border.color: Theme.borderActive
                    border.width: Tokens.strokeWidth
                    Text {
                        anchors.centerIn: parent
                        text: "CONNECT"
                        font.family: Theme.fontDisplay
                        font.pixelSize: Tokens.fontSizeLabel
                        color: Theme.accent
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: backend.connectWithPassword(pskField.text)
                    }
                }
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: Tokens.actionBtnHeight
                    radius: Tokens.radiusSm
                    color: Theme.bgSurface
                    border.color: Theme.borderIdle
                    border.width: Tokens.strokeWidth
                    Text {
                        anchors.centerIn: parent
                        text: "ABORT"
                        font.family: Theme.fontDisplay
                        font.pixelSize: Tokens.fontSizeLabel
                        color: Theme.textMuted
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            pskField.text = ""
                            backend.cancelPassword()
                        }
                    }
                }
            }
        }

        ListView {
            id: list
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: Tokens.spacingXss
            model: backend.networks
            visible: !backend.needsPassword

            delegate: Rectangle {
                width: list.width
                height: Tokens.statBoxHeight
                radius: Tokens.radiusSm
                color: rowMouse.containsMouse ? Theme.bgElevated : Theme.bgSurface
                border.color: model.inUse ? Theme.borderActive : Theme.borderIdle
                border.width: Tokens.strokeWidth

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: Tokens.paddingH
                    spacing: Tokens.spacingXs

                    Text {
                        text: model.signal + "%"
                        font.family: Theme.fontMono
                        font.pixelSize: Tokens.fontSizeTiny
                        color: model.signal > 60 ? Theme.stateSafe
                             : model.signal > 30 ? Theme.stateWarning
                             : Theme.stateCritical
                        Layout.preferredWidth: Tokens.spacingXl
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 0
                        Text {
                            Layout.fillWidth: true
                            text: model.ssid
                            font.family: Theme.fontDisplay
                            font.pixelSize: Tokens.fontSizeLabel
                            color: model.inUse ? Theme.accent : Theme.textPrimary
                            elide: Text.ElideRight
                        }
                        Text {
                            Layout.fillWidth: true
                            text: model.security + (model.inUse ? "  *  LINKED" : "")
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
                    onClicked: {
                        if (model.inUse)
                            backend.disconnectWifi()
                        else
                            backend.connectTo(model.rawSsid, model.security, model.inUse)
                    }
                }
            }

            Text {
                anchors.centerIn: parent
                visible: list.count === 0 && !backend.scanning
                text: "NO NETWORKS"
                font.family: Theme.fontDisplay
                font.pixelSize: Tokens.fontSizeLabel
                color: Theme.textDim
            }
        }
    }

    Timer {
        interval: 15000
        running: root.visible
        repeat: true
        onTriggered: {
            if (!backend.scanning && !backend.connecting && !backend.needsPassword)
                backend.rescan()
        }
    }
}
