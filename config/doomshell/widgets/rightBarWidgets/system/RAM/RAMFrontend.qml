import QtQuick
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

    width:  Globals.rightWidth
    height: Globals.rightWidth * 8 / 7

    RAMBackend {
        id: ram
    }

    Rectangle {
        id: panelBG
        anchors.fill: parent
        radius:       10
        color:        Theme.bgConsole
        opacity:      Theme.opacityConsole
        border.color: Theme.borderConsole
        border.width: Theme.strokeWidth
    }

    Rectangle {
        anchors.top:   parent.top
        anchors.left:  parent.left
        anchors.right: parent.right
        height:        0
        radius:        10
        color:         Theme.accent
        opacity:       0.55
    }

    ColumnLayout {
        anchors.fill:    parent
        anchors.margins: Theme.paddingH
        spacing:         Globals.inMostSpacing * 2

        RowLayout {
            Layout.fillWidth:       true
            Layout.preferredHeight: 20
            spacing:                0

            Repeater {
                model: ["CPU", "GPU", "RAM"]
                Item {
                    Layout.fillWidth: true
                    height:           20

                    Rectangle {
                        anchors.bottom: parent.bottom
                        anchors.left:   parent.left
                        anchors.right:  parent.right
                        height:         1
                        color:          modelData === "RAM" ? Theme.accent : "transparent"
                        opacity:        0.8
                    }

                    Text {
                        anchors.centerIn:   parent
                        text:               modelData
                        font.family:        Theme.fontDisplay
                        font.pixelSize:     Theme.fontSizeLabel
                        color:              modelData === "RAM" ? Theme.accent : Theme.textDim
                        font.letterSpacing: 1.2
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape:  Qt.PointingHandCursor
                        onClicked:    Globals.activePanel = modelData.toLowerCase()
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height:           1
            color:            Theme.borderIdle
            opacity:          0.5
        }

        RowLayout {
            Layout.fillWidth:  true
            Layout.fillHeight: true
            spacing:           Globals.inMostSpacing * 3 / 2
            Rectangle {
                Layout.preferredWidth: 108
                Layout.fillHeight:     true
                color:                 Theme.bgSurface
                radius:                6
                border.color:          Theme.borderIdle
                border.width:          Theme.strokeWidth

                Text {
                    id: procListHeader
                    anchors.top:              parent.top
                    anchors.topMargin:        5
                    anchors.horizontalCenter: parent.horizontalCenter
                    text:                     "PROCESSES"
                    font.family:              Theme.fontDisplay
                    font.pixelSize:           Theme.fontSizeLabel
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
                    currentIndex:         ramFrontend.selectedProc
                    model:                ram.processes

                    delegate: Item {
                        width:  procList.width
                        height: 22

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
                            font.pixelSize:         Theme.fontSizeSmall
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
                                Behavior on width { NumberAnimation { duration: Theme.animFast } }
                            }
                        }

                        Text {
                            id: ramUsage
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.right:          parent.right
                            anchors.rightMargin:    5
                            text:                   model.ram_mb === -1 ? "--" : model.ram_mb
                            font.family:            Theme.fontMono
                            font.pixelSize:         Theme.fontSizeTiny
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
                anchors.margins: Theme.paddingH
                spacing:         Globals.inMostSpacing 
                Rectangle {
                    Layout.fillWidth:  true
                    height          :  ramFrontend.height * 3/14
                    color:             Theme.bgSurface
                    radius:            6
                    border.color:      Theme.borderIdle
                    border.width:      Theme.strokeWidth

                    GridLayout {
                        anchors.fill:    parent
                        anchors.margins: 5
                        rowSpacing:         5
                        columnSpacing:      5
                        columns:            2
                        rows:               3
                        visible: ramFrontend.selectedProcData !== null

                        Text {
                            Layout.alignment: Qt.AlignRight
                            text:           "Process ID: " 
                            font.family:    Theme.fontDisplay
                            font.pixelSize: Theme.fontSizeSmall
                            color:          Theme.textMuted
                        }
                        
                        Text {
                            text:           ramFrontend.selectedProcData?.pid    ?? "—"
                            font.family:    Theme.fontMono
                            font.pixelSize: Theme.fontSizeSmall
                            color:          Theme.textSecondary
                        }

                        Text {
                            Layout.alignment: Qt.AlignRight
                            text:           "Process Name: " 
                            font.family:    Theme.fontDisplay
                            font.pixelSize: Theme.fontSizeSmall
                            color:          Theme.textMuted
                        }
                        
                        Text {
                            text:   ramFrontend.selectedProcData?.name   ?? "—"
                            font.family:    Theme.fontMono
                            font.pixelSize: Theme.fontSizeSmall
                            color:          Theme.textSecondary
                        }

                        Text {
                            Layout.alignment: Qt.AlignRight
                            text:           "RAM Usage: "
                            font.family:    Theme.fontDisplay
                            font.pixelSize: Theme.fontSizeSmall
                            color:          Theme.textMuted
                        }
                        
                        Text {
                            text:           (ramFrontend.selectedProcData?.ram_mb ?? "—") + " MB"
                            font.family:    Theme.fontMono
                            font.pixelSize: Theme.fontSizeSmall
                            color:          Theme.textSecondary
                        }
                    }   
                }

                Rectangle{
                    id: killProcBtn
                    Layout.fillWidth:  true
                    height:            30
                    color:             Theme.bgSurface
                    radius:            6
                    border.color:      Theme.borderIdle
                    border.width:      Theme.strokeWidth
                    Text {
                        anchors.centerIn:   parent
                        text:               "Kill Process"
                        font.family:        Theme.fontDisplay
                        font.pixelSize:     Theme.fontSizeSmall
                        color:              Theme.textMuted
                    }
                }
            }
        }
    }
}