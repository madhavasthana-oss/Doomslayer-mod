import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import QtQuick.Layouts
import "../../../.."
import "../../../../utils"
import "."
Item {
    id: ramFrontend

    property int selectedProc: 0
    property var selectedProcData: (selectedProc >= 0 && selectedProc < ram.processes.count)
                                   ? ram.processes.get(selectedProc)
                                   : null

    width:  Tokens.rightWidth
    height: Tokens.rightWidth * 8 / 7

    RAMBackend {
        id: ram
    }

    ColumnLayout {
        anchors.fill:    parent
        anchors.margins: Tokens.paddingH
        spacing:         Tokens.inMostSpacing * 2

        RowLayout {
            Text {
                id: ramLabel
                Layout.fillWidth:      true
                Layout.alignment:      Qt.AlignHCenter
                horizontalAlignment:   Text.AlignHCenter
                text: "RAM Usage: "
                font.family:    Theme.fontDisplay
                font.pixelSize: Tokens.fontSizeLarge
                color:          Theme.accent
            }

            Text {
                id: ramTotalUsage
                Layout.fillWidth:      true
                Layout.alignment:      Qt.AlignHCenter
                horizontalAlignment:   Text.AlignHCenter
                text: (ram.__ram_in_use__ < 0 || ram.__ram_total__ < 0)
                    ? "-- / -- GB"
                    : ram.__ram_in_use__ + " / " + ram.__ram_total__ + " GB"
                font.family:    Theme.fontMono
                font.pixelSize: Tokens.fontSizeBase
                color:          Theme.accentWarm
            }
        }

        RowLayout {
            Layout.fillWidth:  true
            Layout.fillHeight: true
            spacing:           Tokens.inMostSpacing * 3 / 2
            Rectangle {
                id: procListPanel
                Layout.preferredWidth: 108
                Layout.fillHeight:     true
                color:                  Theme.bgSurface
                radius:                 6
                border.color:           Theme.borderIdle
                border.width:           Tokens.strokeWidth

                Text {
                    id: procListHeader
                    anchors.top:              parent.top
                    anchors.topMargin:        5
                    anchors.horizontalCenter: parent.horizontalCenter
                    text:                     "PROCESSES"
                    font.family:              Theme.fontDisplay
                    font.pixelSize:           Tokens.fontSizeLabel
                    color:                    Theme.textMuted
                    font.letterSpacing:       1.5
                }

                ListView {
                    id: procList
                    anchors.top:          procListHeader.bottom
                    anchors.topMargin:    4
                    anchors.right:        parent.right
                    anchors.rightMargin:  4
                    anchors.left:         parent.left
                    anchors.leftMargin:   4
                    anchors.bottom:       parent.bottom
                    anchors.bottomMargin: 4
                    spacing:              1
                    clip:                 true
                    boundsBehavior:       Flickable.StopAtBounds
                    ScrollBar.vertical: ScrollBar {
                        policy: ScrollBar.AsNeeded
                    }
                    currentIndex:         ramFrontend.selectedProc
                    model:                ram.processes

                    delegate: Item {
                        width:  procList.width
                        height: 26

                        property int   pid:        model.pid
                        property bool  isSelected: index === ramFrontend.selectedProc
                        property color usageColor: model.ram_mb > 1000 ? Theme.stateCritical
                                                 : model.ram_mb > 500 ? Theme.stateWarning
                                                 : Theme.stateSafe

                        Rectangle {
                            anchors.fill: parent
                            color:        isSelected ? Qt.rgba(1, 0.27, 0, 0.18) : "transparent"
                            radius:       3
                            border.color: isSelected ? Theme.accent : "transparent"
                            border.width: isSelected ? 1 : 0
                        }

                        Text {
                            id: procLabel
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left:           parent.left
                            anchors.leftMargin:     5
                            text:                   "P" + model.idx
                            font.family:            Theme.fontDisplay
                            font.pixelSize:         Tokens.fontSizeSmall
                            color:                  isSelected ? Theme.accent : Theme.textMuted
                        }

                        Item {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left:           procLabel.right
                            anchors.leftMargin:     5
                            anchors.right:          ramUsage.left
                            anchors.rightMargin:    3
                            height:                 4

                            Rectangle {
                                anchors.fill: parent
                                radius:       2
                                color:        Theme.bgElevated
                                opacity:      0.8
                            }

                            Rectangle {
                                width:  Math.max(2, parent.width * (model.ram_mb / (ram.__ram_total__  * 1024)))
                                height: parent.height
                                radius: 2
                                color:  usageColor
                                Behavior on width { NumberAnimation { duration: Tokens.animFast } }
                            }
                        }

                        Text {
                            id: ramUsage
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.right:          parent.right
                            anchors.rightMargin:    5
                            text:                   model.ram_mb === -1 ? "--" : model.ram_mb
                            font.family:            Theme.fontMono
                            font.pixelSize:         Tokens.fontSizeTiny
                            color:                  usageColor
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked:    ramFrontend.selectedProc = index
                        }
                    }
                }
            }
            ColumnLayout {
                id: procDataAndControls
                Layout.fillHeight: true
                Layout.fillWidth:  true
                anchors.margins: Tokens.paddingH
                spacing:         Tokens.inMostSpacing 
                Rectangle {
                    id: procDataBox
                    Layout.fillWidth:       true
                    Layout.fillHeight:      true
                    Layout.minimumHeight:   ramFrontend.height * 3/14
                    color:             Theme.bgSurface
                    radius:            6
                    border.color:      Theme.borderIdle
                    border.width:      Tokens.strokeWidth

                    ColumnLayout {
                        anchors.fill:    parent
                        anchors.margins:    5
                        spacing:            1
                        visible: ramFrontend.selectedProcData !== null
                        RowLayout{
                            spacing: Tokens.inMostSpacing * 2 / 5
                            Layout.alignment: Qt.AlignLeft
                            Text {
                                Layout.alignment: Qt.AlignLeft
                                text:           "Process Name: " 
                                font.family:    Theme.fontDisplay
                                font.pixelSize: Tokens.fontSizeTiny
                                color:          Theme.textMuted
                            }
                            
                            Text {
                                Layout.alignment: Qt.AlignLeft
                                text:   ramFrontend.selectedProcData?.name   ?? "—"
                                font.family:    Theme.fontMono
                                font.pixelSize: Tokens.fontSizeTiny
                                color:          Theme.textSecondary
                            }
                        }
                        RowLayout{
                            spacing: Tokens.inMostSpacing * 2 / 5
                            Layout.alignment: Qt.AlignLeft
                            Text {
                                Layout.alignment: Qt.AlignLeft
                                text:           "Process ID: " 
                                font.family:    Theme.fontDisplay
                                font.pixelSize: Tokens.fontSizeTiny
                                color:          Theme.textMuted
                            }
                            
                            Text {
                                Layout.alignment: Qt.AlignLeft
                                text:           ramFrontend.selectedProcData?.pid    ?? "—"
                                font.family:    Theme.fontMono
                                font.pixelSize: Tokens.fontSizeTiny
                                color:          Theme.textSecondary
                            }
                        }

                        RowLayout{
                            spacing: Tokens.inMostSpacing * 2 / 5
                            Layout.alignment: Qt.AlignLeft
                            Text {
                                Layout.alignment: Qt.AlignLeft
                                text:           "RAM Usage: "
                                font.family:    Theme.fontDisplay
                                font.pixelSize: Tokens.fontSizeTiny
                                color:          Theme.textMuted
                            }
                            
                            Text {
                                text:           (ramFrontend.selectedProcData?.ram_mb ?? "—") + " MB"
                                font.family:    Theme.fontMono
                                font.pixelSize: Tokens.fontSizeTiny
                                color:          Theme.textSecondary
                            }
                        }

                        RowLayout{
                            spacing: Tokens.inMostSpacing * 2 / 5
                            Layout.alignment: Qt.AlignLeft
                            Text {
                                Layout.alignment: Qt.AlignLeft
                                text:           "CPU Usage: "
                                font.family:    Theme.fontDisplay
                                font.pixelSize: Tokens.fontSizeTiny
                                color:          Theme.textMuted
                            }
                            
                            Text {
                                text:           (ramFrontend.selectedProcData?.cpu ?? "—") + " %"
                                font.family:    Theme.fontMono
                                font.pixelSize: Tokens.fontSizeTiny
                                color:          Theme.textSecondary
                            }
                        }

                        RowLayout{
                            spacing: Tokens.inMostSpacing * 2 / 5
                            Layout.alignment: Qt.AlignLeft
                            Text {
                                Layout.alignment: Qt.AlignLeft
                                text:           "Uptime: "
                                font.family:    Theme.fontDisplay
                                font.pixelSize: Tokens.fontSizeTiny
                                color:          Theme.textMuted
                            }
                            
                            Text {
                                text:           (ramFrontend.selectedProcData?.uptime ?? "—") + " s"
                                font.family:    Theme.fontMono
                                font.pixelSize: Tokens.fontSizeTiny
                                color:          Theme.textSecondary
                            }
                        }

                        RowLayout{
                            spacing: Tokens.inMostSpacing * 2 / 5
                            Layout.alignment: Qt.AlignLeft
                            Text {
                                Layout.alignment: Qt.AlignLeft
                                text:           "Threads: "
                                font.family:    Theme.fontDisplay
                                font.pixelSize: Tokens.fontSizeTiny
                                color:          Theme.textMuted
                            }

                            Text {
                                text:           ramFrontend.selectedProcData?.threads ?? "—"
                                font.family:    Theme.fontMono
                                font.pixelSize: Tokens.fontSizeTiny
                                color:          Theme.textSecondary
                            }
                        }

                        RowLayout{
                            spacing: Tokens.inMostSpacing * 2 / 5
                            Layout.alignment: Qt.AlignLeft
                                
                            Text {
                                Layout.alignment: Qt.AlignLeft
                                text:           "State: "
                                font.family:    Theme.fontDisplay
                                font.pixelSize: Tokens.fontSizeTiny
                                color:          Theme.textMuted
                            }

                            Text {
                                text: ramFrontend.selectedProcData?.stateDesc ?? "—"
                                font.family:    Theme.fontMono
                                font.pixelSize: Tokens.fontSizeTiny
                                color:          Theme.textSecondary
                            }
                        }

                        RowLayout{
                            spacing: Tokens.inMostSpacing * 2 / 5
                            Layout.alignment: Qt.AlignLeft
                            Text {
                                Layout.alignment: Qt.AlignLeft
                                text:           "User: "
                                font.family:    Theme.fontDisplay
                                font.pixelSize: Tokens.fontSizeTiny
                                color:          Theme.textMuted
                            }

                            Text {
                                text:           ramFrontend.selectedProcData?.user ?? "—"
                                font.family:    Theme.fontMono
                                font.pixelSize: Tokens.fontSizeTiny
                                color:          Theme.textSecondary
                            }
                        }
                    }   
                }

                Item {
                    id: killProcBtn
                    Layout.fillWidth:       true
                    Layout.preferredHeight: 30

                    property color glowColor: Theme.stateCritical
                    property bool  isHovered: killProcMouse.containsMouse
                    property bool  isPressed: killProcMouse.pressed

                    // Soft glow — three stacked, widening, fading rectangles behind the button.
                    Rectangle {
                        anchors.fill:    parent
                        anchors.margins: -10
                        radius:          14
                        color:           "transparent"
                        border.width:    2
                        border.color:    Qt.rgba(killProcBtn.glowColor.r, killProcBtn.glowColor.g, killProcBtn.glowColor.b, killProcBtn.isHovered ? 0.10 : 0)
                        Behavior on border.color { ColorAnimation { duration: Tokens.animMedium } }
                    }
                    Rectangle {
                        anchors.fill:    parent
                        anchors.margins: -5
                        radius:          11
                        color:           "transparent"
                        border.width:    2
                        border.color:    Qt.rgba(killProcBtn.glowColor.r, killProcBtn.glowColor.g, killProcBtn.glowColor.b, killProcBtn.isHovered ? 0.22 : 0)
                        Behavior on border.color { ColorAnimation { duration: Tokens.animMedium } }
                    }
                    Rectangle {
                        anchors.fill:    parent
                        anchors.margins: -2
                        radius:          8
                        color:           "transparent"
                        border.width:    2
                        border.color:    Qt.rgba(killProcBtn.glowColor.r, killProcBtn.glowColor.g, killProcBtn.glowColor.b, killProcBtn.isHovered ? 0.4 : 0)
                        Behavior on border.color { ColorAnimation { duration: Tokens.animMedium } }
                    }

                    Rectangle {
                        id: killProcRect
                        anchors.fill: parent
                        color:        Theme.bgSurface
                        radius:       6
                        border.color: killProcBtn.isHovered ? killProcBtn.glowColor : Theme.borderIdle
                        border.width: killProcBtn.isHovered ? Theme.strokeWidthActive : Theme.strokeWidth
                        opacity:      ramFrontend.selectedProcData !== null ? 1.0 : 0.4
                        scale:        killProcBtn.isPressed ? 0.94 : 1.0

                        Behavior on scale       { NumberAnimation { duration: Tokens.animFast; easing.type: Easing.OutCubic } }
                        Behavior on border.color { ColorAnimation { duration: Tokens.animMedium } }

                        Text {
                            anchors.centerIn:   parent
                            text:               "Kill Process"
                            font.family:        Theme.fontDisplay
                            font.pixelSize:     Tokens.fontSizeSmall
                            color:              killProcBtn.isHovered ? killProcBtn.glowColor : Theme.textMuted
                            Behavior on color { ColorAnimation { duration: Tokens.animMedium } }
                        }
                    }

                    MouseArea {
                        id: killProcMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        enabled:      ramFrontend.selectedProcData !== null
                        cursorShape:  Qt.PointingHandCursor
                        onClicked:    ram.killProcess(ramFrontend.selectedProcData?.pid)
                    }
                }

                Item {
                    id: haltProcBtn
                    Layout.fillWidth:       true
                    Layout.preferredHeight: 30

                    property color glowColor: Theme.stateWarning
                    property bool  isHovered: haltProcMouse.containsMouse
                    property bool  isPressed: haltProcMouse.pressed
                    property bool  isHalted:  ramFrontend.selectedProcData !== null
                                               && ram.__halted_pids__[ramFrontend.selectedProcData.pid] === true

                    Rectangle {
                        anchors.fill:    parent
                        anchors.margins: -10
                        radius:          14
                        color:           "transparent"
                        border.width:    2
                        border.color:    Qt.rgba(haltProcBtn.glowColor.r, haltProcBtn.glowColor.g, haltProcBtn.glowColor.b, haltProcBtn.isHovered ? 0.10 : 0)
                        Behavior on border.color { ColorAnimation { duration: Tokens.animMedium } }
                    }
                    Rectangle {
                        anchors.fill:    parent
                        anchors.margins: -5
                        radius:          11
                        color:           "transparent"
                        border.width:    2
                        border.color:    Qt.rgba(haltProcBtn.glowColor.r, haltProcBtn.glowColor.g, haltProcBtn.glowColor.b, haltProcBtn.isHovered ? 0.22 : 0)
                        Behavior on border.color { ColorAnimation { duration: Tokens.animMedium } }
                    }
                    Rectangle {
                        anchors.fill:    parent
                        anchors.margins: -2
                        radius:          8
                        color:           "transparent"
                        border.width:    2
                        border.color:    Qt.rgba(haltProcBtn.glowColor.r, haltProcBtn.glowColor.g, haltProcBtn.glowColor.b, haltProcBtn.isHovered ? 0.4 : 0)
                        Behavior on border.color { ColorAnimation { duration: Tokens.animMedium } }
                    }

                    Rectangle {
                        id: haltProcRect
                        anchors.fill: parent
                        color:        Theme.bgSurface
                        radius:       6
                        border.color: haltProcBtn.isHovered ? haltProcBtn.glowColor : Theme.borderIdle
                        border.width: haltProcBtn.isHovered ? Theme.strokeWidthActive : Theme.strokeWidth
                        opacity:      ramFrontend.selectedProcData !== null ? 1.0 : 0.4
                        scale:        haltProcBtn.isPressed ? 0.94 : 1.0

                        Behavior on scale        { NumberAnimation { duration: Tokens.animFast; easing.type: Easing.OutCubic } }
                        Behavior on border.color { ColorAnimation { duration: Tokens.animMedium } }

                        AnimatedText {
                            id: haltProcAnimText
                            anchors.fill: parent
                            mode:         AnimatedText.Mode.Scramble
                            duration:     280

                            Text {
                                anchors.fill:       parent
                                text:               haltProcAnimText.displayedText
                                font.family:        Theme.fontDisplay
                                font.pixelSize:      Tokens.fontSizeSmall
                                color:              haltProcBtn.isHovered ? haltProcBtn.glowColor : Theme.textMuted
                                opacity:            haltProcAnimText.displayOpacity
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment:   Text.AlignVCenter
                                Behavior on color { ColorAnimation { duration: Tokens.animMedium } }
                            }

                            Component.onCompleted: {
                                displayedText = haltProcBtn.isHalted ? "Resume Process" : "Halt Process"
                                targetText    = displayedText
                            }
                        }

                        Connections {
                            target: haltProcBtn
                            function onIsHaltedChanged() {
                                haltProcAnimText.transitionTo(haltProcBtn.isHalted ? "Resume Process" : "Halt Process")
                            }
                        }
                    }

                    MouseArea {
                        id: haltProcMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        enabled:      ramFrontend.selectedProcData !== null
                        cursorShape:  Qt.PointingHandCursor
                        onClicked:    ram.toggleHaltProcess(ramFrontend.selectedProcData?.pid)
                    }
                }

                Item {
                    id: optimizeProcBtn
                    Layout.fillWidth:       true
                    Layout.preferredHeight: 30

                    property color glowColor: Theme.accent
                    property bool  isHovered: optimizeProcMouse.containsMouse
                    property bool  isPressed: optimizeProcMouse.pressed

                    Rectangle {
                        anchors.fill:    parent
                        anchors.margins: -10
                        radius:          14
                        color:           "transparent"
                        border.width:    2
                        border.color:    Qt.rgba(optimizeProcBtn.glowColor.r, optimizeProcBtn.glowColor.g, optimizeProcBtn.glowColor.b, optimizeProcBtn.isHovered ? 0.10 : 0)
                        Behavior on border.color { ColorAnimation { duration: Tokens.animMedium } }
                    }
                    Rectangle {
                        anchors.fill:    parent
                        anchors.margins: -5
                        radius:          11
                        color:           "transparent"
                        border.width:    2
                        border.color:    Qt.rgba(optimizeProcBtn.glowColor.r, optimizeProcBtn.glowColor.g, optimizeProcBtn.glowColor.b, optimizeProcBtn.isHovered ? 0.22 : 0)
                        Behavior on border.color { ColorAnimation { duration: Tokens.animMedium } }
                    }
                    Rectangle {
                        anchors.fill:    parent
                        anchors.margins: -2
                        radius:          8
                        color:           "transparent"
                        border.width:    2
                        border.color:    Qt.rgba(optimizeProcBtn.glowColor.r, optimizeProcBtn.glowColor.g, optimizeProcBtn.glowColor.b, optimizeProcBtn.isHovered ? 0.4 : 0)
                        Behavior on border.color { ColorAnimation { duration: Tokens.animMedium } }
                    }

                    Rectangle {
                        id: optimizeProcRect
                        anchors.fill: parent
                        color:        Theme.bgSurface
                        radius:       6
                        border.color: optimizeProcBtn.isHovered ? optimizeProcBtn.glowColor : Theme.borderIdle
                        border.width: optimizeProcBtn.isHovered ? Theme.strokeWidthActive : Theme.strokeWidth
                        opacity:      ramFrontend.selectedProcData !== null ? 1.0 : 0.4
                        scale:        optimizeProcBtn.isPressed ? 0.94 : 1.0

                        Behavior on scale        { NumberAnimation { duration: Tokens.animFast; easing.type: Easing.OutCubic } }
                        Behavior on border.color { ColorAnimation { duration: Tokens.animMedium } }

                        Text {
                            anchors.centerIn:   parent
                            text:               "Optimize Process"
                            font.family:        Theme.fontDisplay
                            font.pixelSize:     Tokens.fontSizeSmall
                            color:              optimizeProcBtn.isHovered ? optimizeProcBtn.glowColor : Theme.textMuted
                            Behavior on color { ColorAnimation { duration: Tokens.animMedium } }
                        }
                    }

                    MouseArea {
                        id: optimizeProcMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        enabled:      ramFrontend.selectedProcData !== null
                        cursorShape:  Qt.PointingHandCursor
                        onClicked:    ram.optimizeProcess(ramFrontend.selectedProcData?.pid)
                    }
                }
            }
        }

        Item {
            id: ramTuiBtn
            Layout.fillWidth:       true
            Layout.preferredHeight: 30

            property color glowColor: Theme.accentSoft
            property bool  isHovered: ramTuiMouse.containsMouse
            property bool  isPressed: ramTuiMouse.pressed
            property bool  isAvailable: ram.__ram_tui_available__

            Rectangle {
                anchors.fill:    parent
                anchors.margins: -10
                radius:          14
                color:           "transparent"
                border.width:    2
                border.color:    Qt.rgba(ramTuiBtn.glowColor.r, ramTuiBtn.glowColor.g, ramTuiBtn.glowColor.b, ramTuiBtn.isHovered ? 0.10 : 0)
                Behavior on border.color { ColorAnimation { duration: Tokens.animMedium } }
            }
            Rectangle {
                anchors.fill:    parent
                anchors.margins: -5
                radius:          11
                color:           "transparent"
                border.width:    2
                border.color:    Qt.rgba(ramTuiBtn.glowColor.r, ramTuiBtn.glowColor.g, ramTuiBtn.glowColor.b, ramTuiBtn.isHovered ? 0.22 : 0)
                Behavior on border.color { ColorAnimation { duration: Tokens.animMedium } }
            }
            Rectangle {
                anchors.fill:    parent
                anchors.margins: -2
                radius:          8
                color:           "transparent"
                border.width:    2
                border.color:    Qt.rgba(ramTuiBtn.glowColor.r, ramTuiBtn.glowColor.g, ramTuiBtn.glowColor.b, ramTuiBtn.isHovered ? 0.4 : 0)
                Behavior on border.color { ColorAnimation { duration: Tokens.animMedium } }
            }

            Rectangle {
                id: ramTuiRect
                anchors.fill: parent
                color:        Theme.bgSurface
                radius:       6
                border.color: ramTuiBtn.isHovered ? ramTuiBtn.glowColor : Theme.borderIdle
                border.width: ramTuiBtn.isHovered ? Theme.strokeWidthActive : Theme.strokeWidth
                opacity:      ramTuiBtn.isAvailable ? 1.0 : 0.4
                scale:        ramTuiBtn.isPressed ? 0.94 : 1.0

                Behavior on scale        { NumberAnimation { duration: Tokens.animFast; easing.type: Easing.OutCubic } }
                Behavior on border.color { ColorAnimation { duration: Tokens.animMedium } }

                Text {
                    anchors.centerIn:   parent
                    text:               ramTuiBtn.isAvailable ? "Launch RAM Manager" : "RAM Manager TUI Not Found"
                    font.family:        Theme.fontDisplay
                    font.pixelSize:     Tokens.fontSizeSmall
                    color:              ramTuiBtn.isHovered ? ramTuiBtn.glowColor : Theme.textMuted
                    Behavior on color { ColorAnimation { duration: Tokens.animMedium } }
                }
            }

            MouseArea {
                id: ramTuiMouse
                anchors.fill: parent
                hoverEnabled: true
                enabled:      ramTuiBtn.isAvailable
                cursorShape:  Qt.PointingHandCursor
                onClicked:    ram.launchRamTui()
            }
        }
    }
}