// SettingsFrontend.qml --- doom-flavored quick settings (T.S.S content)
import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import "../../.."
import "."

Item {
    id: root
    implicitWidth:  Tokens.edgeWidgetWidth - 2 * Tokens.paddingH
    implicitHeight: Tokens.edgeWidgetHeight * 0.62

    signal requestClose()

    SettingsBackend {
        id: backend
        onRequestClose: root.requestClose()
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: Tokens.spacingSm

        Text {
            text: "SETTINGS"
            font.family: Theme.fontDisplay
            font.pixelSize: Tokens.fontSizeLabel
            color: Theme.accent
        }

        Text {
            Layout.fillWidth: true
            visible: backend.statusMsg.length > 0
            text: backend.statusMsg
            font.family: Theme.fontMono
            font.pixelSize: Tokens.fontSizeTiny
            color: Theme.textSecondary
            elide: Text.ElideRight
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Tokens.spacingXs

            Item {
                Layout.preferredWidth: Tokens.iconSizeMedium
                Layout.preferredHeight: Tokens.iconSizeMedium
                Image {
                    id: brightGlyph
                    anchors.fill: parent
                    source: Theme.iconBrightness
                    sourceSize: Qt.size(width, height)
                    visible: false
                }
                ColorOverlay {
                    anchors.fill: brightGlyph
                    source: brightGlyph
                    color: Theme.textMuted
                }
            }

            Text {
                text: "SCR"
                font.family: Theme.fontDisplay
                font.pixelSize: Tokens.fontSizeLabel
                color: Theme.textDim
                Layout.preferredWidth: Tokens.spacingXl
            }

            // Click-track slider
            Rectangle {
                id: brightTrack
                Layout.fillWidth: true
                Layout.preferredHeight: Tokens.usageBarHeight + Tokens.spacingXs
                radius: Tokens.radiusSm
                color: Theme.bgElevated

                Rectangle {
                    width: parent.width * (backend.brightness / 100)
                    height: parent.height
                    radius: parent.radius
                    color: Theme.accent
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: (mouse) => backend.setBrightness((mouse.x / width) * 100)
                    onPositionChanged: (mouse) => {
                        if (pressed)
                            backend.setBrightness((mouse.x / width) * 100)
                    }
                }
            }

            Text {
                text: backend.brightness + "%"
                font.family: Theme.fontMono
                font.pixelSize: Tokens.fontSizeTiny
                color: Theme.textSecondary
                Layout.preferredWidth: Tokens.spacingXl + Tokens.spacingSm
                horizontalAlignment: Text.AlignRight
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Tokens.spacingXs

            Item {
                Layout.preferredWidth: Tokens.iconSizeMedium
                Layout.preferredHeight: Tokens.iconSizeMedium
                Image {
                    id: volGlyph
                    anchors.fill: parent
                    source: Theme.iconAudio
                    sourceSize: Qt.size(width, height)
                    visible: false
                }
                ColorOverlay {
                    anchors.fill: volGlyph
                    source: volGlyph
                    color: backend.muted ? Theme.stateCritical : Theme.textMuted
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: backend.toggleMute()
                }
            }

            Text {
                text: "VOL"
                font.family: Theme.fontDisplay
                font.pixelSize: Tokens.fontSizeLabel
                color: Theme.textDim
                Layout.preferredWidth: Tokens.spacingXl
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: Tokens.usageBarHeight + Tokens.spacingXs
                radius: Tokens.radiusSm
                color: Theme.bgElevated

                Rectangle {
                    width: parent.width * Math.min(backend.volume, 100) / 100
                    height: parent.height
                    radius: parent.radius
                    color: backend.muted ? Theme.textDim : Theme.accent
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: (mouse) => backend.setVolume((mouse.x / width) * 100)
                    onPositionChanged: (mouse) => {
                        if (pressed)
                            backend.setVolume((mouse.x / width) * 100)
                    }
                }
            }

            Text {
                text: backend.muted ? "M" : (backend.volume + "%")
                font.family: Theme.fontMono
                font.pixelSize: Tokens.fontSizeTiny
                color: Theme.textSecondary
                Layout.preferredWidth: Tokens.spacingXl + Tokens.spacingSm
                horizontalAlignment: Text.AlignRight
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Tokens.spacingXs

            Item {
                Layout.preferredWidth: Tokens.iconSizeMedium
                Layout.preferredHeight: Tokens.iconSizeMedium
                Image {
                    id: kbdGlyph
                    anchors.fill: parent
                    source: Theme.iconKbd
                    sourceSize: Qt.size(width, height)
                    visible: false
                }
                ColorOverlay {
                    anchors.fill: kbdGlyph
                    source: kbdGlyph
                    color: Theme.textMuted
                }
            }

            Text {
                text: "KBD"
                font.family: Theme.fontDisplay
                font.pixelSize: Tokens.fontSizeLabel
                color: Theme.textDim
                Layout.preferredWidth: Tokens.spacingXl
            }

            Repeater {
                model: backend.kbdMax + 1
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: Tokens.actionBtnHeight
                    radius: Tokens.radiusSm
                    color: index <= backend.kbdBrightness ? Theme.bgElevated : Theme.bgSurface
                    border.color: index <= backend.kbdBrightness ? Theme.borderActive : Theme.borderIdle
                    border.width: Tokens.strokeWidth
                    Text {
                        anchors.centerIn: parent
                        text: String(index)
                        font.family: Theme.fontMono
                        font.pixelSize: Tokens.fontSizeTiny
                        color: index <= backend.kbdBrightness ? Theme.accent : Theme.textDim
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: backend.setKbd(index)
                    }
                }
            }
        }

        // Separator
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: Tokens.strokeWidth
            color: Theme.borderIdle
            opacity: 0.5
        }

        GridLayout {
            Layout.fillWidth: true
            columns: 2
            rowSpacing: Tokens.spacingXs
            columnSpacing: Tokens.spacingXs

            Repeater {
                model: [
                    { key: "gnome",  label: "GNOME-CONTROLS", icon: Theme.iconThemeApp },
                    { key: "shot",  label: "SCREENSHOT", icon: Theme.iconScreenshot },
                    { key: "rec",   label: Globals.screenRecording ? "STOP REC" : "RECORD", icon: Theme.iconRecord },
                    { key: "mute",  label: backend.muted ? "UNMUTE" : "MUTE", icon: Theme.iconAudio }
                ]

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: Tokens.edgeToggleHeight
                    radius: Tokens.radiusMd
                    color: tileMouse.containsMouse ? Theme.bgElevated : Theme.bgSurface
                    border.color: (modelData.key === "rec" && Globals.screenRecording)
                        ? Theme.stateCritical : Theme.borderIdle
                    border.width: Tokens.strokeWidth

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: Tokens.paddingH
                        spacing: Tokens.spacingXs

                        Item {
                            Layout.preferredWidth: Tokens.iconSizeMedium
                            Layout.preferredHeight: Tokens.iconSizeMedium
                            Image {
                                id: actGlyph
                                anchors.fill: parent
                                source: modelData.icon
                                sourceSize: Qt.size(width, height)
                                visible: false
                            }
                            ColorOverlay {
                                anchors.fill: actGlyph
                                source: actGlyph
                                color: (modelData.key === "rec" && Globals.screenRecording)
                                    ? Theme.stateCritical : Theme.textMuted
                            }
                        }

                        Text {
                            Layout.fillWidth: true
                            text: modelData.label
                            font.family: Theme.fontDisplay
                            font.pixelSize: Tokens.fontSizeLabel
                            color: Theme.textPrimary
                            elide: Text.ElideRight
                        }
                    }

                    MouseArea {
                        id: tileMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            switch (modelData.key) {
                            case "gnome": backend.launchGnome(); break
                            case "shot": backend.screenshot(); break
                            case "rec":  backend.toggleRecord(); break
                            case "mute": backend.toggleMute(); break
                            }
                        }
                    }
                }
            }
        }

        Item { Layout.fillHeight: true }
    }
}
