import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import "../utils"
import ".."
import "../widgets/centerBarWidgets/system/CPU"
import "../widgets/centerBarWidgets/system/GPU"
import "../widgets/centerBarWidgets/system/RAM"
import "../widgets/centerBarWidgets/system/temp"

Item {
    id: centerBar
    width:  Globals.centerWidth
    height: Globals.centerHeight
    property string activePanel: ""

    // load CPU Stats
    CPUStats{
        id: cpuPopup
        visible: false
        anchors.top: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
    }
    
    GPUStats{
        id: gpuPopup
        visible: false
        anchors.top: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
    }

    RAMStats{
        id: ramPopup
        visible: false
        anchors.top: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
    }

    TempStats{
        id: tempPopup
        visible: false
        anchors.top: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
    }
    Timer {
        id: clockTimer
        interval: 1000
        running:  true
        repeat:   true
        onTriggered: timeText.text = Qt.formatTime(new Date(), "hh:mm")
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
    //  SHAPE
    // ---------------------------------------------------------

    CenterTrapezoid {
        anchors.fill: parent
        barWidth:     Globals.centerWidth
        barHeight:    Globals.centerHeight
        alertActive:  false
        expanded:     activePanel !== ""
    }

    // ---------------------------------------------------------
    //  CONTENT
    //  GridLayout — 5 columns, 2 rows
    //  Row 0: labels — CPU  GPU  Greetings  RAM  BAT
    //  Row 1: values — X%   Y%   23:52      Z%   W%
    // ---------------------------------------------------------

    GridLayout {
        anchors.centerIn: parent
        columns:          Globals.columnCount
        rows:             Globals.rowCount
        rowSpacing:       2
        columnSpacing:    Globals.columnSpacing

        // ── ROW 0 — labels ──────────────────────────────────

        Text {
            Layout.alignment: Qt.AlignVCenter
            text:             "CPU"
            font.family:      kogni.name
            font.pixelSize:   Theme.fontSizeBase
            color:            Theme.textMuted

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    activePanel =
                        activePanel === "cpu"
                        ? ""
                        : "cpu"
                }
            }
        }

        Text {
            Layout.alignment: Qt.AlignVCenter
            text:             "GPU"
            font.family:      kogni.name
            font.pixelSize:   Theme.fontSizeBase
            color:            Theme.textMuted
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            text:             "Greetings, Slayer"
            font.family:      kogni.name
            font.pixelSize:   Theme.fontSizeMedium
            color:            Theme.textPrimary
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            text:             "RAM"
            font.family:      kogni.name
            font.pixelSize:   Theme.fontSizeBase
            color:            Theme.textMuted
        }

        Text {
            Layout.alignment: Qt.AlignVCenter
            text:             "Temp"
            font.family:      kogni.name
            font.pixelSize:   Theme.fontSizeBase
            color:            Theme.textMuted
        }

        // ── ROW 1 — values ──────────────────────────────────

        Text {
            Layout.alignment: Qt.AlignHCenter
            text:             cpuPopup.__cpu_usage__ + " %"
            font.family:      jetbrains.name
            font.pixelSize:   Theme.fontSizeSmall
            color:            Theme.textSecondary
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            text:             gpuPopup.__gpu_usage__ + " %"
            font.family:      jetbrains.name
            font.pixelSize:   Theme.fontSizeSmall
            color:            Theme.textSecondary
        }

        Text {
            id:               timeText
            Layout.alignment: Qt.AlignHCenter
            text:             Qt.formatTime(new Date(), "hh:mm")
            font.family:      jetbrains.name
            font.pixelSize:   Theme.fontSizeSmall
            color:            Theme.textSecondary
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            text:             ramPopup.__ram_in_use__ + "/" + ramPopup.__ram_total__ + " gB"
            font.family:      jetbrains.name
            font.pixelSize:   Theme.fontSizeSmall
            color:            Theme.textSecondary
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            text:             tempPopup.__temp__ + " \u00B0C"
            font.family:      jetbrains.name
            font.pixelSize:   Theme.fontSizeSmall
            color:            Theme.textSecondary
        }
    }
}