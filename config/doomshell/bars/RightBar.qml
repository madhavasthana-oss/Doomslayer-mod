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
    width: Globals.rightWidth
    height: Globals.rightHeight

    function __gradient__(
        color1,
        color2,
        alpha
    ){
        // gradient helper, transitions slowly 
        // and uniformly from one color to another
        color1 = color1.toString()
        color2 = color2.toString()
        let r1 = parseInt(color1.slice(1, 3), 16)
        let g1 = parseInt(color1.slice(3, 5), 16)
        let b1 = parseInt(color1.slice(5, 7), 16)

        let r2 = parseInt(color2.slice(1, 3), 16)
        let g2 = parseInt(color2.slice(3, 5), 16)
        let b2 = parseInt(color2.slice(5, 7), 16)

        return "#" 
        + Math.round(
            (1 - alpha) * r1 + alpha * r2
        ).toString(16).padStart(2,"0")
        + Math.round(
            (1 - alpha) * g1 + alpha * g2
        ).toString(16).padStart(2,"0")
        + Math.round(
            (1 - alpha) * b1 + alpha * b2
        ).toString(16).padStart(2,"0")
    }
    // ---------------------------------------------------------
    //  FONTS
    // ---------------------------------------------------------

    FontLoader {
        id: kogni
        source: "../assets/fonts/KogniGear.ttf"
    }

    FontLoader {
        id: jetbrains
        source: "../assets/fonts/JetBrainsMonoNerdFontMono-Regular.ttf"
    }

    // ---------------------------------------------------------
    //  PROCESSES
    //  Declared here, triggered on demand
    // ---------------------------------------------------------

    Process {
        id: procShutdown
        command: ["systemctl", "poweroff"]
    }

    Process {
        id: procReboot
        command: ["systemctl", "reboot"]
    }

    Process {
        id: procSleep
        command: ["systemctl", "suspend"]
    }

    Process {
        id: procLogout
        command: ["hyprctl", "dispatch", "exit"]
    }

    Process {
        id: procBluetooth
        command: ["blueman-manager"]
    }

    Process {
        id: procWifi
        command: ["nm-connection-editor"]
    }

    Process {
        id: procSettings
        command: ["nwg-look"]
    }

    // Battery stats loader

    BATStats{
        id: batStat
        visible: false
        anchors.top: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        onReady:{
            batLabel.opacity = 1
            batPercent.opacity = 1
            constBatBar.opacity = 1
            varBatBar.opacity = 1
        }
    }

    Volume{
        id: audioStat
        visible: false
        anchors.top: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        onReady:{
            volLabel.opacity = 1
            volPercent.opacity = 1
            constVolBar.opacity = 1
            varVolBar.opacity = 1
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
    //  POWER MENU STATE
    //  Toggles the power popup visibility
    // ---------------------------------------------------------

    property bool powerMenuOpen: false

    // ---------------------------------------------------------
    //  CONTENT
    // ---------------------------------------------------------

    RowLayout {
        anchors.fill:        parent
        anchors.leftMargin:  Globals.rightHeight + Globals.inMostSpacing // respects angled left edge
        anchors.rightMargin: Globals.inMostSpacing
        spacing:             Globals.inMostSpacing * 1.2

        // ---------------------------------------------------------
        //  ZONE 1 — Battery + Volume stats
        //
        //  BAT  88%  [========--]
        //  VOL  72%  [=======---]
        // ---------------------------------------------------------

        GridLayout {
            columns:     3
            rows:        2
            rowSpacing:  2
            columnSpacing: 4
            Layout.alignment: Qt.AlignVCenter

            // BAT label
            Text {
                id:             batLabel
                text:           "BAT"
                font.family:    kogni.name
                font.pixelSize: Theme.fontSizeLabel
                color:          Theme.textMuted
                opacity:        0  // start invisible

                Behavior on opacity {
                    NumberAnimation {
                        duration:    Globals.activeWindowAndBatteryAndVolumeAnim
                        easing.type: Easing.OutCubic
                    }
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
                Behavior on opacity{
                    NumberAnimation{
                        duration: Globals.activeWindowAndBatteryAndVolumeAnim
                        easing.type: Easing.OutCubic
                    }
                }
            }

            // BAT bar
            Rectangle {
                id:     constBatBar
                width:  50
                height: 4
                color:  Theme.borderIdle
                radius: 25
                opacity: 0
                Rectangle {
                    id:     varBatBar
                    width:  parent.width * batStat.percentage * 0.01
                    height: parent.height
                    color:  __gradient__(Theme.stateSafe, Theme.stateCritical, 1.00 - (batStat.percentage / 100))
                    radius: 25
                    opacity: 0
                    Behavior on opacity{
                        NumberAnimation{
                            duration: Globals.activeWindowAndBatteryAndVolumeAnim
                            easing.type: Easing.OutCubic
                        }
                    }
                }
                Behavior on opacity{
                    NumberAnimation{
                        duration: Globals.activeWindowAndBatteryAndVolumeAnim
                        easing.type: Easing.OutCubic
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
                Behavior on opacity{
                    NumberAnimation{
                        duration: Globals.activeWindowAndBatteryAndVolumeAnim
                        easing.type: Easing.OutCubic
                    }
                }
            }

            // VOL percentage
            Text {
                id:             volPercent
                text:           audioStat.muted ? 0 : audioStat.volume
                font.family:    jetbrains.name
                font.pixelSize: Theme.fontSizeLabel
                color:          Theme.textSecondary
                opacity:        0
                Behavior on opacity{
                    NumberAnimation{
                        duration: Globals.activeWindowAndBatteryAndVolumeAnim
                        easing.type: Easing.OutCubic
                    }
                }
            }

            // VOL bar
            Rectangle {
                id:     constVolBar
                width:  50
                height: 4
                color:  Theme.borderIdle
                radius: 25
                opacity:0

                Rectangle {
                    id:     varVolBar
                    width:  parent.width * audioStat.volume / 100
                    height: parent.height
                    color:  Theme.accent
                    radius: 25
                    opacity: 0
                Behavior on opacity{
                    NumberAnimation{
                        duration: Globals.activeWindowAndBatteryAndVolumeAnim
                        easing.type: Easing.OutCubic
                    }
                }
                }
                Behavior on opacity{
                    NumberAnimation{
                        duration: Globals.activeWindowAndBatteryAndVolumeAnim
                        easing.type: Easing.OutCubic
                    }
                }
            }
        }

    //     // Separator
    //     Rectangle {
    //         width:            1
    //         height:           parent.height * 0.6
    //         color:            Theme.borderIdle
    //         Layout.alignment: Qt.AlignVCenter
    //     }

    //     // ---------------------------------------------------------
    //     //  ZONE 2 — Toggle Row
    //     //  bluetooth | wifi | display | settings
    //     // ---------------------------------------------------------

    //     RowLayout {
    //         spacing:          Globals.inMostSpacing
    //         Layout.alignment: Qt.AlignVCenter

    //         // Bluetooth
    //         Text {
    //             text:           "󰂯"
    //             font.family:    jetbrains.name
    //             font.pixelSize: Theme.iconSizeSmall
    //             color:          Theme.textMuted

    //             HoverHandler { id: btHover }
    //             ToolTip.visible: btHover.hovered
    //             ToolTip.text:    "Bluetooth"
    //             ToolTip.delay:   400

    //             MouseArea {
    //                 anchors.fill: parent
    //                 onClicked:    procBluetooth.running = true
    //             }
    //         }

    //         // Wifi
    //         Text {
    //             text:           "󰤨"
    //             font.family:    jetbrains.name
    //             font.pixelSize: Theme.iconSizeSmall
    //             color:          Theme.textMuted

    //             HoverHandler { id: wifiHover }
    //             ToolTip.visible: wifiHover.hovered
    //             ToolTip.text:    "Network"
    //             ToolTip.delay:   400

    //             MouseArea {
    //                 anchors.fill: parent
    //                 onClicked:    procWifi.running = true
    //             }
    //         }

    //         // Settings
    //         Text {
    //             text:           "󰒓"
    //             font.family:    jetbrains.name
    //             font.pixelSize: Theme.iconSizeSmall
    //             color:          Theme.textMuted

    //             HoverHandler { id: settingsHover }
    //             ToolTip.visible: settingsHover.hovered
    //             ToolTip.text:    "Settings"
    //             ToolTip.delay:   400

    //             MouseArea {
    //                 anchors.fill: parent
    //                 onClicked:    procSettings.running = true
    //             }
    //         }
    //     }

    //     // Separator
    //     Rectangle {
    //         width:            1
    //         height:           parent.height * 0.6
    //         color:            Theme.borderIdle
    //         Layout.alignment: Qt.AlignVCenter
    //     }

    //     // ---------------------------------------------------------
    //     //  ZONE 3 — Power Button
    //     // ---------------------------------------------------------

    //     Text {
    //         text:             "⏻"
    //         font.family:      jetbrains.name
    //         font.pixelSize:   Theme.iconSizeSmall
    //         color:            rightBar.powerMenuOpen
    //                               ? Theme.stateCritical
    //                               : Theme.textMuted
    //         Layout.alignment: Qt.AlignVCenter

    //         Behavior on color {
    //             ColorAnimation { duration: 120; easing.type: Easing.OutCubic }
    //         }

    //         HoverHandler { id: powerHover }
    //         ToolTip.visible: powerHover.hovered
    //         ToolTip.text:    "Power"
    //         ToolTip.delay:   400

    //         MouseArea {
    //             anchors.fill: parent
    //             onClicked:    rightBar.powerMenuOpen = !rightBar.powerMenuOpen
    //         }
    //     }
    // }

    // // ---------------------------------------------------------
    // //  POWER MENU POPUP
    // //  Slides down from the bar when powerMenuOpen is true
    // // ---------------------------------------------------------

    // Rectangle {
    //     id:      powerMenu
    //     visible: rightBar.powerMenuOpen
    //     width:   120
    //     height:  powerMenuOpen ? 100 : 0
    //     color:   Theme.bgSurface
    //     border.color: Theme.stateCritical
    //     border.width: 1

    //     anchors.top:   parent.bottom
    //     anchors.right: parent.right
    //     anchors.topMargin: 4

    //     Behavior on height {
    //         NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
    //     }

    //     ColumnLayout {
    //         anchors.fill:    parent
    //         anchors.margins: 8
    //         spacing:         4

    //         Repeater {
    //             model: [
    //                 { label: "Sleep",     icon: "󰒲", action: "sleep"     },
    //                 { label: "Reboot",    icon: "󰜉", action: "reboot"    },
    //                 { label: "Logout",    icon: "󰍃", action: "logout"    },
    //                 { label: "Shutdown",  icon: "⏻", action: "shutdown"  }
    //             ]

    //             RowLayout {
    //                 spacing: 6
    //                 Layout.fillWidth: true

    //                 Text {
    //                     text:           modelData.icon
    //                     font.family:    jetbrains.name
    //                     font.pixelSize: Theme.fontSizeSmall
    //                     color:          Theme.textMuted
    //                 }

    //                 Text {
    //                     text:           modelData.label
    //                     font.family:    kogni.name
    //                     font.pixelSize: Theme.fontSizeSmall
    //                     color:          Theme.textSecondary
    //                     Layout.fillWidth: true
    //                 }

    //                 MouseArea {
    //                     anchors.fill: parent
    //                     onClicked: {
    //                         rightBar.powerMenuOpen = false
    //                         if      (modelData.action === "sleep")    procSleep.running    = true
    //                         else if (modelData.action === "reboot")   procReboot.running   = true
    //                         else if (modelData.action === "logout")   procLogout.running   = true
    //                         else if (modelData.action === "shutdown") procShutdown.running = true
    //                     }
    //                 }
    //             }
    //         }
    //     }
    }
}