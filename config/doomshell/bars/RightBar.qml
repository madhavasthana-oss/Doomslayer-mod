import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.DBusMenu
import QtQuick
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import "../utils"
import ".."
import "../widgets/rightBarWidgets/power"
import "../widgets/rightBarWidgets/audio"

Item {
    id: rightBar
    width:  Globals.rightWidth
    height: Globals.rightHeight

    // ---------------------------------------------------------
    //  GRADIENT HELPER
    // ---------------------------------------------------------

    function __gradient__(color1, color2, alpha) {
        color1 = color1.toString()
        color2 = color2.toString()
        let r1 = parseInt(color1.slice(1, 3), 16)
        let g1 = parseInt(color1.slice(3, 5), 16)
        let b1 = parseInt(color1.slice(5, 7), 16)
        let r2 = parseInt(color2.slice(1, 3), 16)
        let g2 = parseInt(color2.slice(3, 5), 16)
        let b2 = parseInt(color2.slice(5, 7), 16)
        return "#"
            + Math.round((1 - alpha) * r1 + alpha * r2).toString(16).padStart(2, "0")
            + Math.round((1 - alpha) * g1 + alpha * g2).toString(16).padStart(2, "0")
            + Math.round((1 - alpha) * b1 + alpha * b2).toString(16).padStart(2, "0")
    }

    // ---------------------------------------------------------
    //  FONTS
    // ---------------------------------------------------------

    FontLoader { id: kogni;     source: "../assets/fonts/KogniGear.ttf" }
    FontLoader { id: jetbrains; source: "../assets/fonts/JetBrainsMonoNerdFontMono-Regular.ttf" }

    // ---------------------------------------------------------
    //  PROCESSES
    // ---------------------------------------------------------

    Process { id: procShutdown; command: ["systemctl", "poweroff"]                }
    Process { id: procReboot;   command: ["systemctl", "reboot"]                  }
    Process { id: procSleep;    command: ["systemctl", "suspend"]                 }
    Process { id: procLogout;   command: ["hyprctl", "dispatch", "exit"]          }
    Process { id: procLock;     command: ["hyprlock"]                             }
    Process { id: procBluetooth;command: ["blueman-manager"]                      }
    Process { id: procWifi;     command: ["nm-connection-editor"]                 }
    Process { id: procSettings; command: ["nwg-look"]                             }

    // ---------------------------------------------------------
    //  STAT LOADERS
    // ---------------------------------------------------------

    BATStats {
        id:      batStat
        visible: false
        anchors.top:              parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        onReady: {
            batLabel.opacity    = 1
            batPercent.opacity  = 1
            constBatBar.opacity = 1
            varBatBar.opacity   = 1
        }
    }

    Volume {
        id:      audioStat
        visible: false
        anchors.top:              parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        onReady: {
            volLabel.opacity    = 1
            volPercent.opacity  = 1
            constVolBar.opacity = 1
            varVolBar.opacity   = 1
        }
    }

    // ---------------------------------------------------------
    //  SHAPE
    // ---------------------------------------------------------

    RightTrapezoid {
        anchors.fill: parent
        barWidth:     Globals.rightWidth
        barHeight:    Globals.rightHeight
        alertActive:  false
    }

    // ---------------------------------------------------------
    //  CONTENT ROW
    // ---------------------------------------------------------

    RowLayout {
        anchors.fill:        parent
        anchors.leftMargin:  Globals.rightHeight + Globals.inMostSpacing
        anchors.rightMargin: Globals.inMostSpacing
        spacing:             Globals.inMostSpacing

        // ---------------------------------------------------------
        //  ZONE 1 — Battery + Volume
        // ---------------------------------------------------------

        GridLayout {
            columns:          3
            rows:             2
            rowSpacing:       2
            columnSpacing:    4
            Layout.alignment: Qt.AlignHCenter
            Layout.fillWidth: false

            // BAT label
            Text {
                id:             batLabel
                text:           "BAT"
                font.family:    kogni.name
                font.pixelSize: Theme.fontSizeLabel
                color:          Theme.textMuted
                opacity:        0
                Behavior on opacity {
                    NumberAnimation { duration: Globals.activeWindowAndBatteryAndVolumeAnim; easing.type: Easing.OutCubic }
                }
            }

            // BAT percentage
            Text {
                id:             batPercent
                text:           batStat.percentage + "%"
                font.family:    jetbrains.name
                font.pixelSize: Theme.fontSizeLabel
                color:          Theme.textSecondary
                opacity:        0
                Behavior on opacity {
                    NumberAnimation { duration: Globals.activeWindowAndBatteryAndVolumeAnim; easing.type: Easing.OutCubic }
                }
            }

            // BAT bar
            Rectangle {
                id:      constBatBar
                width:   50
                height:  4
                color:   Theme.borderIdle
                radius:  25
                opacity: 0
                Behavior on opacity {
                    NumberAnimation { duration: Globals.activeWindowAndBatteryAndVolumeAnim; easing.type: Easing.OutCubic }
                }
                Rectangle {
                    id:      varBatBar
                    width:   parent.width * batStat.percentage * 0.01
                    height:  parent.height
                    color:   __gradient__(Theme.stateSafe, Theme.stateCritical, 1.00 - (batStat.percentage / 100))
                    radius:  25
                    opacity: 0
                    Behavior on opacity {
                        NumberAnimation { duration: Globals.activeWindowAndBatteryAndVolumeAnim; easing.type: Easing.OutCubic }
                    }
                }
            }

            // VOL label
            Text {
                id:             volLabel
                text:           "VOL"
                font.family:    kogni.name
                font.pixelSize: Theme.fontSizeLabel
                color:          Theme.textMuted
                opacity:        0
                Behavior on opacity {
                    NumberAnimation { duration: Globals.activeWindowAndBatteryAndVolumeAnim; easing.type: Easing.OutCubic }
                }
            }

            // VOL percentage
            Text {
                id:             volPercent
                text:           audioStat.muted ? "M" : audioStat.volume + "%"
                font.family:    jetbrains.name
                font.pixelSize: Theme.fontSizeLabel
                color:          audioStat.muted ? Theme.textMuted : Theme.textSecondary
                opacity:        0
                Behavior on opacity {
                    NumberAnimation { duration: Globals.activeWindowAndBatteryAndVolumeAnim; easing.type: Easing.OutCubic }
                }
                Behavior on color {
                    ColorAnimation { duration: 120; easing.type: Easing.OutCubic }
                }
            }

            // VOL bar
            Rectangle {
                id:      constVolBar
                width:   50
                height:  4
                color:   Theme.borderIdle
                radius:  25
                opacity: 0
                Behavior on opacity {
                    NumberAnimation { duration: Globals.activeWindowAndBatteryAndVolumeAnim; easing.type: Easing.OutCubic }
                }
                Rectangle {
                    id:      varVolBar
                    width:   parent.width * audioStat.volume / 100
                    height:  parent.height
                    color:   audioStat.muted ? Theme.borderIdle : Theme.accent
                    radius:  25
                    opacity: 0
                    Behavior on opacity {
                        NumberAnimation { duration: Globals.activeWindowAndBatteryAndVolumeAnim; easing.type: Easing.OutCubic }
                    }
                    Behavior on color {
                        ColorAnimation { duration: 120; easing.type: Easing.OutCubic }
                    }
                }
            }
        }

        // ---------------------------------------------------------
        //  SEPARATOR 1
        // ---------------------------------------------------------

        Item { Layout.preferredWidth: Globals.inMostSpacing; Layout.fillWidth: false }

        Rectangle {
            Layout.preferredWidth:  1
            Layout.preferredHeight: parent.height * 0.6
            Layout.fillWidth:       false
            Layout.alignment:       Qt.AlignHCenter
            color:                  Theme.borderIdle
        }

        Item { Layout.preferredWidth: Globals.inMostSpacing; Layout.fillWidth: false }

        // ---------------------------------------------------------
        //  ZONE 2 — Toggle Row
        // ---------------------------------------------------------

        RowLayout {
            spacing:          Globals.inMostSpacing * 2
            Layout.fillWidth: false
            Layout.alignment: Qt.AlignHCenter

            // Bluetooth
            Text {
                id:             btIcon
                text:           "󰂯"
                font.family:    kogni.name
                font.pixelSize: Theme.iconSizeSmall
                color:          btHover.hovered ? Theme.accent : Theme.textMuted
                Behavior on color { ColorAnimation { duration: 120; easing.type: Easing.OutCubic } }
                HoverHandler    { id: btHover }
                MouseArea { anchors.fill: parent; onClicked: procBluetooth.running = true }
            }

            // Wifi
            Text {
                id:             wifiIcon
                text:           "󰤨"
                font.family:    kogni.name
                font.pixelSize: Theme.iconSizeSmall
                color:          wifiHover.hovered ? Theme.accent : Theme.textMuted
                Behavior on color { ColorAnimation { duration: 120; easing.type: Easing.OutCubic } }
                HoverHandler    { id: wifiHover }
                MouseArea { anchors.fill: parent; onClicked: procWifi.running = true }
            }

            // Settings
            Text {
                id:             settingsIcon
                text:           "󰒓"
                font.family:    kogni.name
                font.pixelSize: Theme.iconSizeSmall
                color:          settingsHover.hovered ? Theme.accent : Theme.textMuted
                Behavior on color { ColorAnimation { duration: 120; easing.type: Easing.OutCubic } }
                HoverHandler    { id: settingsHover }
                MouseArea { anchors.fill: parent; onClicked: procSettings.running = true }
            }
        }

        // ---------------------------------------------------------
        //  SEPARATOR 2
        // ---------------------------------------------------------

        Item { Layout.preferredWidth: Globals.inMostSpacing; Layout.fillWidth: false }

        Rectangle {
            Layout.preferredWidth:  1
            Layout.preferredHeight: parent.height * 0.6
            Layout.fillWidth:       false
            Layout.alignment:       Qt.AlignHCenter
            color:                  Theme.borderIdle
        }

        Item { Layout.preferredWidth: Globals.inMostSpacing; Layout.fillWidth: false }

        // ---------------------------------------------------------
        //  ZONE 3 — Power Actions: lock · sleep · reboot · shutdown
        // ---------------------------------------------------------

        RowLayout {
            spacing:          Globals.inMostSpacing * 2
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter

            // Lock Screen — 󰍁
            Text {
                text:           "󰍁"
                font.family:    kogni.name
                font.pixelSize: Theme.iconSizeSmall
                color:          lockHover.hovered ? Theme.accent : Theme.textMuted
                Behavior on color { ColorAnimation { duration: 120; easing.type: Easing.OutCubic } }
                HoverHandler { id: lockHover }
                MouseArea {
                    anchors.fill:     parent
                    onClicked:        procLock.running = true
                    ToolTip.visible:  lockHover.hovered
                    ToolTip.text:     "Lock Screen"
                    ToolTip.delay:    500
                }
            }

            // Sleep — 󰒲
            Text {
                text:           "󰒲"
                font.family:    kogni.name
                font.pixelSize: Theme.iconSizeSmall
                color:          sleepHover.hovered ? Theme.accent : Theme.textMuted
                Behavior on color { ColorAnimation { duration: 120; easing.type: Easing.OutCubic } }
                HoverHandler { id: sleepHover }
                MouseArea {
                    anchors.fill:     parent
                    onClicked:        procSleep.running = true
                    ToolTip.visible:  sleepHover.hovered
                    ToolTip.text:     "Sleep"
                    ToolTip.delay:    500
                }
            }

            // Reboot — 󰜉
            Text {
                text:           "󰜉"
                font.family:    kogni.name
                font.pixelSize: Theme.iconSizeSmall
                color:          rebootHover.hovered ? Theme.accent : Theme.textMuted
                Behavior on color { ColorAnimation { duration: 120; easing.type: Easing.OutCubic } }
                HoverHandler { id: rebootHover }
                MouseArea {
                    anchors.fill:     parent
                    onClicked:        procReboot.running = true
                    ToolTip.visible:  rebootHover.hovered
                    ToolTip.text:     "Reboot"
                    ToolTip.delay:    500
                }
            }

            // Shutdown — ⏻
            Text {
                text:           "⏻"
                font.family:    kogni.name
                font.pixelSize: Theme.iconSizeSmall
                color:          shutdownHover.hovered ? Theme.stateCritical : Theme.textMuted
                Behavior on color { ColorAnimation { duration: 120; easing.type: Easing.OutCubic } }
                HoverHandler { id: shutdownHover }
                MouseArea {
                    anchors.fill:     parent
                    onClicked:        procShutdown.running = true
                    ToolTip.visible:  shutdownHover.hovered
                    ToolTip.text:     "Shut Down"
                    ToolTip.delay:    500
                }
            }
        }
    }
}