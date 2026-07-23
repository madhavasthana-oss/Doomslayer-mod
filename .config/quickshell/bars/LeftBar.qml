import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import "../utils"
import ".."

Item {
    id: leftBar
    width:  Tokens.leftWidth
    height: Tokens.leftHeight
    property int visibleCount: Globals.workspaceNumber
    property int focusedId:    Hyprland.focusedWorkspace?.id ?? 1
    property int windowStart:  1    // starts at 1, updated by Connections

    // Cell size for each workspace number (room for double digits + click padding)
    readonly property int wsCellWidth: Tokens.fontSizeSmall + Tokens.spacingXs
    readonly property int wsRowSpacing: Tokens.spacingXs
    // Must include inter-item spacing or cells overflow into the separator
    readonly property int wsRowWidth:
        visibleCount * wsCellWidth
        + Math.max(0, visibleCount - 1) * wsRowSpacing

    Connections {
        target: Hyprland
        function onFocusedWorkspaceChanged() {
            var id = Hyprland.focusedWorkspace?.id ?? 1
            leftBar.focusedId = id

            // hit right boundary --- shift forward
            if (id >= leftBar.windowStart + leftBar.visibleCount) {
                leftBar.windowStart = id - leftBar.visibleCount + 1
            }
            // hit left boundary --- shift backward
            else if (id < leftBar.windowStart) {
                leftBar.windowStart = id
            }
            // within range --- don't touch windowStart
        }
    }

    // Hyprland 0.55+ with Lua config no longer accepts legacy
    // "workspace N" strings. Dispatch must be an hl.dsp.* form.
    function switchToWorkspace(id) {
        if (Hyprland.usingLua)
            Hyprland.dispatch("hl.dsp.focus({ workspace = " + id + " })")
        else
            Hyprland.dispatch("workspace " + id)
    }

    //  SHAPE

    LeftTrapezoid {
        anchors.fill: parent
        barWidth:     Tokens.leftWidth
        barHeight:    Tokens.leftHeight
        alertActive:  false
    }

    //  CONTENT
    //  Left  -> workspace numbers (fixed width, never shrinks)
    //  Sep   -> thin bar with fixed gaps so it never sits on the numbers
    //  Right -> active window title (takes remaining space)

    RowLayout {
        anchors.fill:        parent
        anchors.leftMargin:  Tokens.workspaceToggleMargin
        anchors.rightMargin: Tokens.leftHeight + Tokens.spacingXs
        spacing:             Tokens.spacingXss

        //  Workspace numbers --- locked width
        RowLayout {
            Layout.alignment:      Qt.AlignVCenter
            Layout.preferredWidth: leftBar.wsRowWidth
            Layout.minimumWidth:   leftBar.wsRowWidth
            Layout.maximumWidth:   leftBar.wsRowWidth
            Layout.fillWidth:      false
            Layout.fillHeight:     true
            spacing:               leftBar.wsRowSpacing

            Repeater {
                model: Array.from(
                    { length: leftBar.visibleCount },
                    (_, i) => leftBar.windowStart + i
                )

                Item {
                    id: wsDelegate
                    property int  wsId:     modelData
                    property bool isActive: Hyprland.focusedWorkspace?.id === wsId

                    Layout.fillHeight:     true
                    Layout.preferredWidth: leftBar.wsCellWidth
                    Layout.minimumWidth:   leftBar.wsCellWidth
                    Layout.maximumWidth:   leftBar.wsCellWidth

                    Text {
                        anchors.centerIn: parent
                        text:             wsDelegate.wsId
                        font.family:      Theme.fontDisplay
                        font.pixelSize:   Tokens.fontSizeSmall
                        color:            wsDelegate.isActive ? Theme.textSecondary : Theme.textMuted

                        Behavior on color {
                            ColorAnimation { duration: Tokens.animFast; easing.type: Easing.OutCubic }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape:  Qt.PointingHandCursor
                        onClicked:    leftBar.switchToWorkspace(wsDelegate.wsId)
                    }
                }
            }
        }

        // Fixed gap before separator
        Item {
            Layout.preferredWidth: Tokens.spacingMd
            Layout.minimumWidth:   Tokens.spacingMd
            Layout.fillWidth:      false
        }

        // Separator bar
        Rectangle {
            Layout.preferredWidth:  Math.max(1, Math.round(Tokens.strokeWidth))
            Layout.preferredHeight: parent.height * 0.5
            Layout.fillWidth:       false
            Layout.fillHeight:      false
            Layout.alignment:       Qt.AlignVCenter
            color:                  Theme.borderIdle
        }

        // Fixed gap after separator
        Item {
            Layout.preferredWidth: Tokens.spacingMd
            Layout.minimumWidth:   Tokens.spacingMd
            Layout.fillWidth:      false
        }

        // Active window title --- only flex child
        Text {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            elide: Text.ElideRight

            text: (
                Hyprland.activeToplevel &&
                Hyprland.activeToplevel.workspace &&
                Hyprland.focusedWorkspace &&
                Hyprland.activeToplevel.workspace.id === Hyprland.focusedWorkspace.id
            ) ? Hyprland.activeToplevel.title : "Desktop"

            font.family: Theme.fontDisplay
            font.pixelSize: Tokens.fontSizeSmall
            color: Theme.textSecondary
        }
    }
}
