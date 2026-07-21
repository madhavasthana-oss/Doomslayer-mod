// NotifFrontend.qml — notification inbox + silent/dnd (T.S.S content)
import QtQuick
import QtQuick.Layouts
import "../../.."
import "."

Item {
    id: root
    implicitWidth:  Tokens.edgeWidgetWidth - 2 * Tokens.paddingH
    implicitHeight: Tokens.edgeWidgetHeight * 0.62

    NotifBackend { id: backend }

    ColumnLayout {
        anchors.fill: parent
        spacing: Tokens.spacingXs

        RowLayout {
            Layout.fillWidth: true
            spacing: Tokens.spacingXs

            Text {
                text: "NOTIFICATIONS"
                font.family: Theme.fontDisplay
                font.pixelSize: Tokens.fontSizeLabel
                color: Theme.accent
            }

            Item { Layout.fillWidth: true }

            // SILENT
            Rectangle {
                Layout.preferredHeight: Tokens.listRowHeight
                Layout.preferredWidth: silentLbl.implicitWidth + 2 * Tokens.paddingH
                radius: Tokens.radiusSm
                color: backend.silent ? Theme.bgElevated : Theme.bgSurface
                border.color: backend.silent ? Theme.borderActive : Theme.borderIdle
                border.width: Tokens.strokeWidth
                Text {
                    id: silentLbl
                    anchors.centerIn: parent
                    text: "SILENT"
                    font.family: Theme.fontDisplay
                    font.pixelSize: Tokens.fontSizeLabel
                    color: backend.silent ? Theme.accent : Theme.textDim
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: backend.toggleSilent()
                }
            }

            // DND
            Rectangle {
                Layout.preferredHeight: Tokens.listRowHeight
                Layout.preferredWidth: dndLbl.implicitWidth + 2 * Tokens.paddingH
                radius: Tokens.radiusSm
                color: backend.dnd ? Theme.bgElevated : Theme.bgSurface
                border.color: backend.dnd ? Theme.stateCritical : Theme.borderIdle
                border.width: Tokens.strokeWidth
                Text {
                    id: dndLbl
                    anchors.centerIn: parent
                    text: "DND"
                    font.family: Theme.fontDisplay
                    font.pixelSize: Tokens.fontSizeLabel
                    color: backend.dnd ? Theme.stateCritical : Theme.textDim
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: backend.toggleDnd()
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Text {
                Layout.fillWidth: true
                text: backend.statusMsg
                font.family: Theme.fontMono
                font.pixelSize: Tokens.fontSizeTiny
                color: Theme.textSecondary
                elide: Text.ElideRight
            }
            Rectangle {
                Layout.preferredHeight: Tokens.listRowHeight
                Layout.preferredWidth: clearLbl.implicitWidth + 2 * Tokens.paddingH
                radius: Tokens.radiusSm
                color: Theme.bgSurface
                border.color: Theme.borderIdle
                border.width: Tokens.strokeWidth
                Text {
                    id: clearLbl
                    anchors.centerIn: parent
                    text: "CLEAR"
                    font.family: Theme.fontDisplay
                    font.pixelSize: Tokens.fontSizeLabel
                    color: Theme.textMuted
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: backend.dismissAll()
                }
            }
        }

        ListView {
            id: list
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: Tokens.spacingXss
            model: backend.notifications

            delegate: Rectangle {
                width: list.width
                height: Math.max(Tokens.statBoxHeight, bodyCol.implicitHeight + 2 * Tokens.paddingV)
                radius: Tokens.radiusSm
                color: Theme.bgSurface
                border.color: model.urgency === "critical" ? Theme.stateCritical
                            : model.urgency === "low" ? Theme.borderIdle
                            : Theme.borderIdle
                border.width: Tokens.strokeWidth

                ColumnLayout {
                    id: bodyCol
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: Tokens.paddingH
                    spacing: Tokens.spacingXss

                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            Layout.fillWidth: true
                            text: model.appName
                            font.family: Theme.fontMono
                            font.pixelSize: Tokens.fontSizeTiny
                            color: Theme.textDim
                            elide: Text.ElideRight
                        }
                        Text {
                            text: "✕"
                            font.pixelSize: Tokens.fontSizeSmall
                            color: dismissMouse.containsMouse ? Theme.accent : Theme.textDim
                            MouseArea {
                                id: dismissMouse
                                anchors.fill: parent
                                anchors.margins: -Tokens.spacingXs
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: backend.dismissId(model.notifId)
                            }
                        }
                    }

                    Text {
                        Layout.fillWidth: true
                        text: model.summary
                        font.family: Theme.fontDisplay
                        font.pixelSize: Tokens.fontSizeLabel
                        color: Theme.textPrimary
                        wrapMode: Text.Wrap
                    }

                    Text {
                        Layout.fillWidth: true
                        visible: model.body.length > 0
                        text: model.body
                        font.family: Theme.fontMono
                        font.pixelSize: Tokens.fontSizeTiny
                        color: Theme.textSecondary
                        wrapMode: Text.Wrap
                        maximumLineCount: 3
                        elide: Text.ElideRight
                    }
                }
            }

            Text {
                anchors.centerIn: parent
                visible: list.count === 0
                text: backend.dnd ? "DND ACTIVE" : "NO TRANSMISSIONS"
                font.family: Theme.fontDisplay
                font.pixelSize: Tokens.fontSizeLabel
                color: Theme.textDim
            }
        }
    }
}
