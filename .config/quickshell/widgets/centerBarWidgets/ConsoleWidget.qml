// ConsoleWidget.qml --- app codex: ListView + AnimatedText briefing (once per boot)
import QtQuick
import QtQuick.Layouts
import Quickshell
import "../.."
import "../../utils"
import "console"

Item {
    id: root

    implicitWidth:  Tokens.centerSmallerWidth
    implicitHeight: Tokens.centerExpandedHeight

    // session cache: title -> true once typewriter has fired this boot
    property var typedOnce: ({})
    property int selectedIndex: 0

    ConsoleModel { id: codex }

    function selectIndex(i) {
        if (i < 0 || i >= codex.codexModel.count)
            return
        selectedIndex = i
        if (appList.currentIndex !== i)
            appList.currentIndex = i
        appList.positionViewAtIndex(i, ListView.Contain)

        const row = codex.codexModel.get(i)
        const key = row.title
        const desc = row.description

        if (root.typedOnce[key]) {
            // Already briefed this boot --- snap text, no re-type
            descAnim.stop()
            descAnim.displayedText = desc
            descAnim.targetText = desc
        } else {
            descAnim.transitionTo(desc)
            // mark after starting so mid-animation reselect still skips later
            let cache = root.typedOnce
            cache[key] = true
            root.typedOnce = cache
        }
    }

    function launchSelected() {
        const row = codex.codexModel.get(selectedIndex)
        if (!row)
            return
        // execCmd may contain args --- run via bash -lc for "ghostty -e nvim"
        Quickshell.execDetached(["bash", "-lc", row.execCmd])
    }

    function iconSource(name) {
        // theme icon name -> file path; fall back to empty
        const p = Quickshell.iconPath(name, true)
        return p && p.length ? p : ""
    }

    function grabListFocus() {
        appList.forceActiveFocus()
    }

    Component.onCompleted: {
        selectIndex(0)
        grabListFocus()
    }

    // When user switches to CONSOLE tab, reclaim keyboard for Enter / arrows
    Connections {
        target: Globals
        function onActiveCenterPanelChanged() {
            if (Globals.activeCenterPanel === "console")
                Qt.callLater(root.grabListFocus)
        }
    }

    // Root-level keys as fallback if focus is somewhere in this panel
    focus: true
    Keys.forwardTo: [appList]
    Keys.onPressed: (event) => {
        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            root.launchSelected()
            event.accepted = true
        } else if (event.key === Qt.Key_Up) {
            root.selectIndex(root.selectedIndex - 1)
            event.accepted = true
        } else if (event.key === Qt.Key_Down) {
            root.selectIndex(root.selectedIndex + 1)
            event.accepted = true
        }
    }

    RowLayout {
        id: mainRow
        anchors.fill: parent
        anchors.margins: Tokens.paddingH
        spacing: Tokens.spacingMd

        // -- LEFT: application list ---
        ColumnLayout {
            Layout.preferredWidth: Tokens.listPanelWidth * 1.6
            Layout.fillHeight: true
            spacing: Tokens.spacingXs

            Text {
                text: "CODEX"
                font.family: Theme.fontDisplay
                font.pixelSize: Tokens.fontSizeLabel
                color: Theme.accent
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: Tokens.radiusMd
                color: Theme.bgSurface
                border.color: Theme.borderIdle
                border.width: Tokens.strokeWidth

                ListView {
                    id: appList
                    anchors.fill: parent
                    anchors.margins: Tokens.paddingH
                    clip: true
                    spacing: Tokens.spacingXss
                    model: codex.codexModel
                    currentIndex: root.selectedIndex
                    focus: true
                    activeFocusOnTab: true
                    keyNavigationEnabled: false
                    highlightFollowsCurrentItem: true

                    Keys.onPressed: (event) => {
                        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            root.launchSelected()
                            event.accepted = true
                        } else if (event.key === Qt.Key_Up) {
                            root.selectIndex(root.selectedIndex - 1)
                            event.accepted = true
                        } else if (event.key === Qt.Key_Down) {
                            root.selectIndex(root.selectedIndex + 1)
                            event.accepted = true
                        }
                    }

                    delegate: Rectangle {
                        width: appList.width
                        height: Tokens.statBoxHeight
                        radius: Tokens.radiusSm
                        color: index === root.selectedIndex ? Theme.bgElevated : "transparent"
                        border.color: index === root.selectedIndex ? Theme.borderActive : "transparent"
                        border.width: Tokens.strokeWidth

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: Tokens.paddingH
                            spacing: Tokens.spacingXs

                            Image {
                                Layout.preferredWidth: Tokens.iconSizeLarge
                                Layout.preferredHeight: Tokens.iconSizeLarge
                                source: root.iconSource(model.icon)
                                sourceSize: Qt.size(width, height)
                                fillMode: Image.PreserveAspectFit
                                asynchronous: true
                            }

                            Text {
                                Layout.fillWidth: true
                                text: model.title.toUpperCase()
                                font.family: Theme.fontDisplay
                                font.pixelSize: Tokens.fontSizeLabel
                                color: index === root.selectedIndex ? Theme.accent : Theme.textMuted
                                elide: Text.ElideRight
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.selectIndex(index)
                                appList.forceActiveFocus()
                            }
                            onDoubleClicked: {
                                root.selectIndex(index)
                                root.launchSelected()
                            }
                        }
                    }
                }
            }
        }

        // -- RIGHT: name + class + animated description ---
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: Tokens.spacingSm

            // Header: icon + title
            RowLayout {
                Layout.fillWidth: true
                spacing: Tokens.spacingMd

                Rectangle {
                    Layout.preferredWidth: Tokens.statBoxHeight + Tokens.spacingMd
                    Layout.preferredHeight: Tokens.statBoxHeight + Tokens.spacingMd
                    radius: Tokens.radiusMd
                    color: Theme.bgSurface
                    border.color: Theme.borderIdle
                    border.width: Tokens.strokeWidth

                    Image {
                        anchors.centerIn: parent
                        width: Tokens.iconSizeLarge * 2
                        height: Tokens.iconSizeLarge * 2
                        source: {
                            const row = codex.codexModel.get(root.selectedIndex)
                            return row ? root.iconSource(row.icon) : ""
                        }
                        sourceSize: Qt.size(width, height)
                        fillMode: Image.PreserveAspectFit
                        asynchronous: true
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Tokens.spacingXss

                    Text {
                        Layout.fillWidth: true
                        text: {
                            const row = codex.codexModel.get(root.selectedIndex)
                            return row ? row.title.toUpperCase() : ""
                        }
                        font.family: Theme.fontDisplay
                        font.pixelSize: Tokens.fontSizeMedium
                        color: Theme.textPrimary
                        elide: Text.ElideRight
                    }

                    Text {
                        Layout.fillWidth: true
                        text: {
                            const row = codex.codexModel.get(root.selectedIndex)
                            // e.g. A reliable... style classification line
                            return row ? ("<< " + row.classification + " >>") : ""
                        }
                        font.family: Theme.fontMono
                        font.pixelSize: Tokens.fontSizeSmall
                        color: Theme.textSecondary
                        wrapMode: Text.WordWrap
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: Tokens.strokeWidth
                color: Theme.borderIdle
                opacity: 0.5
            }

            // Description stage
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: Tokens.radiusMd
                color: Theme.bgSurface
                border.color: Theme.borderIdle
                border.width: Tokens.strokeWidth

                AnimatedText {
                    id: descAnim
                    mode: AnimatedText.Mode.Typewriter
                    duration: Tokens.animSlow * 3
                }

                Text {
                    anchors.fill: parent
                    anchors.margins: Tokens.paddingH
                    text: descAnim.displayedText
                    font.family: Theme.fontMono
                    font.pixelSize: Tokens.fontSizeSmall
                    color: Theme.textPrimary
                    wrapMode: Text.WordWrap
                    opacity: descAnim.displayOpacity
                    verticalAlignment: Text.AlignTop
                }
            }

            // Launch
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: Tokens.actionBtnHeight
                radius: Tokens.radiusSm
                color: launchMouse.containsMouse ? Theme.bgElevated : Theme.bgSurface
                border.color: Theme.borderActive
                border.width: Tokens.strokeWidth

                Text {
                    anchors.centerIn: parent
                    text: "DEPLOY"
                    font.family: Theme.fontDisplay
                    font.pixelSize: Tokens.fontSizeLabel
                    color: Theme.accent
                }
                MouseArea {
                    id: launchMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.launchSelected()
                }
            }
        }
    }
}
