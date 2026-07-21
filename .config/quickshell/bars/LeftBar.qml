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

    Connections {
        target: Hyprland
        function onFocusedWorkspaceChanged() {
            var id = Hyprland.focusedWorkspace?.id ?? 1
            leftBar.focusedId = id

            // hit right boundary — shift forward
            if (id >= leftBar.windowStart + leftBar.visibleCount) {
                leftBar.windowStart = id - leftBar.visibleCount + 1
            }
            // hit left boundary — shift backward
            else if (id < leftBar.windowStart) {
                leftBar.windowStart = id
            }
            // within range — don't touch windowStart
        }
    }
    //  FONTS

    FontLoader {
        id: kogni
        source: "../assets/fonts/KogniGear.ttf"
    }

    FontLoader {
        id: jetbrains
        source: "../assets/fonts/JetBrainsMonoNerdFontMono-Regular.ttf"
    }

    //  SHAPE

    LeftTrapezoid {
        anchors.fill: parent
        barWidth:     Tokens.leftWidth
        barHeight:    Tokens.leftHeight
        alertActive:  false
    }


    // ---------------------------------------------------------
    //  CONTENT
    //  Two RowLayouts side by side:
    //  Left  → workspace numbers
    //  Right → active window icons in current workspace
    // ---------------------------------------------------------

    RowLayout {
    anchors.fill:        parent
    anchors.leftMargin:  Tokens.workspaceToggleMargin
    anchors.rightMargin: Tokens.leftHeight + Tokens.spacingXs 
    spacing:             Tokens.barMarginTop

    // ---------------------------------------------------------
    //  ROW 1 — Workspace Numbers — FIXED WIDTH
    // ---------------------------------------------------------
    RowLayout {
      Layout.alignment: Qt.AlignJustify
        Layout.preferredWidth: Globals.workspaceNumber * (Tokens.fontSizeSmall + Tokens.spacingXs)
        Layout.fillWidth:      false  // never grow or shrink
        spacing:               Tokens.spacingXs 

        Repeater {
            model: Array.from(
                { length: leftBar.visibleCount },
                (_, i) => leftBar.windowStart + i
            )

            Text {
                property int  wsId:     modelData
                property bool isActive: Hyprland.focusedWorkspace?.id === wsId

                text:           wsId
                font.family:    kogni.name
                font.pixelSize: Tokens.fontSizeSmall
                color:          isActive ? Theme.textSecondary : Theme.textMuted

                Behavior on color {
                    ColorAnimation { duration: Tokens.animFast; easing.type: Easing.OutCubic }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: Hyprland.dispatch("workspace " + wsId)
                }
            }
        }
    }
      
    Item {
      Layout.fillWidth: true 
    }
    // Separator — now always at fixed position
        Rectangle {
            Layout.preferredWidth:  Tokens.strokeWidth
            Layout.preferredHeight: parent.height * 0.5
            Layout.fillWidth:       false
            Layout.alignment:       Qt.AlignVCenter
            color:                  Theme.borderIdle
          }

    Item {
      Layout.fillWidth: true 
    }

    // ---------------------------------------------------------
    //  ROW 2 — Active Window Name
    // ---------------------------------------------------------
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

            font.family: kogni.name
            font.pixelSize: Tokens.fontSizeSmall
            color: Theme.textSecondary
        }
    }
}
