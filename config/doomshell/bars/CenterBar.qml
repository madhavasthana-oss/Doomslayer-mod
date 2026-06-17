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
    property string gpuLoading: "Loading."
    property string cpuLoading: "Loading."
    property string ramLoading: "Loading."
    property string tempLoading: "Loading."
    // add loading helper
    // load CPU Stats
    CPUStats{
        id: cpuPopup
        visible: false
        anchors.top: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
    }

    Timer{
        id: cpuTimer
        interval: 500
        running: !cpuPopup.__is_ready__
        repeat: true
        onTriggered: {
            centerBar.cpuLoading = (centerBar.cpuLoading == "Loading." ? 
                      "Loading.." : (
                        centerBar.cpuLoading == "Loading.." 
                        ? "Loading..." : "Loading."
                      ))
        }   
    }
    
    GPUStats{
        id: gpuPopup
        visible: false
        anchors.top: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
    }
    Timer{
        id: gpuTimer
        interval: 500
        running: !gpuPopup.__is_ready__
        repeat: true
        onTriggered: {
            centerBar.gpuLoading = (centerBar.gpuLoading == "Loading." ? 
                      "Loading.." : (
                        centerBar.gpuLoading == "Loading.." 
                        ? "Loading..." : "Loading."
                      ))
        }   
    }
    

    RAMStats{
        id: ramPopup
        visible: false
        anchors.top: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
    }
    Timer{
        id: ramTimer
        interval: 500
        running: !ramPopup.__is_ready__
        repeat: true
        onTriggered: {
            centerBar.ramLoading = (centerBar.ramLoading == "Loading." ? 
                      "Loading.." : (
                        centerBar.ramLoading == "Loading.." 
                        ? "Loading..." : "Loading."
                      ))
        }   
    }

    TempStats{
        id: tempPopup
        visible: false
        anchors.top: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
    }
    Timer{
        id: tempTimer
        interval: 500
        running: !tempPopup.__is_ready__
        repeat: true
        onTriggered: {
            centerBar.tempLoading = (centerBar.tempLoading == "Loading." ? 
                      "Loading.." : (
                        centerBar.tempLoading == "Loading.." 
                        ? "Loading..." : "Loading."
                      ))
        }   
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
        rowSpacing:       1
        columnSpacing:    Globals.columnSpacing
        Layout.fillWidth: false

        // ── ROW 0 — labels ──────────────────────────────────

        Text {
            Layout.preferredWidth: Globals.preferredWidthNoGreeting
            id              : cpu
            Layout.alignment: Qt.AlignVCenter
            text:             "CPU"
            horizontalAlignment: Text.AlignHCenter
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
            id:               gpu
            Layout.preferredWidth: Globals.preferredWidthNoGreeting
            Layout.alignment: Qt.AlignHCenter
            text:             "GPU"
            horizontalAlignment: Text.AlignHCenter
            font.family:      kogni.name
            font.pixelSize:   Theme.fontSizeBase
            color:            Theme.textMuted
        }

        Text {
            Layout.preferredWidth: Globals.greetingWidth
            Layout.alignment: Qt.AlignHCenter
            text:             "Greetings, Slayer"
            horizontalAlignment: Text.AlignHCenter
            font.family:      kogni.name
            font.pixelSize:   Theme.fontSizeMedium
            color:            Theme.textPrimary
        }

        Text {
            Layout.preferredWidth: Globals.preferredWidthNoGreeting
            Layout.alignment: Qt.AlignHCenter
            text:             "RAM"
            horizontalAlignment: Text.AlignHCenter
            font.family:      kogni.name
            font.pixelSize:   Theme.fontSizeBase
            color:            Theme.textMuted
        }

        Text {
            Layout.preferredWidth: Globals.preferredWidthNoGreeting
            Layout.alignment: Qt.AlignHCenter
            text:             "Temp"
            horizontalAlignment: Text.AlignHCenter
            font.family:      kogni.name
            font.pixelSize:   Theme.fontSizeBase
            color:            Theme.textMuted
        }

        // ── ROW 1 — values ──────────────────────────────────

        Text {
            id              : cpuStat
            Layout.preferredWidth: Globals.preferredWidthNoGreeting
            Layout.alignment: Qt.AlignHCenter
            horizontalAlignment: Text.AlignHCenter
            text:             !cpuPopup.__is_ready__ ? centerBar.cpuLoading : cpuPopup.__cpu_usage__ + " %"
            font.family:      jetbrains.name
            font.pixelSize:   Theme.fontSizeSmall
            color:            Theme.textSecondary
        }

        Text {
            id:               gpuStat
            Layout.preferredWidth: Globals.preferredWidthNoGreeting
            Layout.alignment: Qt.AlignHCenter
            text:             !gpuPopup.__is_ready__ ? centerBar.gpuLoading : gpuPopup.__gpu_usage__ + " %"
            horizontalAlignment: Text.AlignHCenter
            font.family:      jetbrains.name
            font.pixelSize:   Theme.fontSizeSmall
            color:            Theme.textSecondary
        }

        Text {
            Layout.preferredWidth: Globals.greetingWidth
            id:               timeText
            Layout.alignment: Qt.AlignHCenter
            text:             Qt.formatTime(new Date(), "hh:mm")
            horizontalAlignment: Text.AlignHCenter
            font.family:      jetbrains.name
            font.pixelSize:   Theme.fontSizeSmall
            color:            Theme.textSecondary
        }

        Text {
            Layout.preferredWidth: Globals.preferredWidthNoGreeting
            Layout.alignment: Qt.AlignHCenter
            text:             !ramPopup.__is_ready__ ? centerBar.ramLoading : ramPopup.__ram_in_use__ + "/" + ramPopup.__ram_total__ + " gB"
            horizontalAlignment: Text.AlignHCenter
            font.family:      jetbrains.name
            font.pixelSize:   Theme.fontSizeSmall
            color:            Theme.textSecondary
        }

        Text {
            Layout.preferredWidth: Globals.preferredWidthNoGreeting
            Layout.alignment: Qt.AlignHCenter
            text:             !tempPopup.__is_ready__ ? centerBar.tempLoading : tempPopup.__temp__ + " \u00B0C"
            font.family:      jetbrains.name
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize:   Theme.fontSizeSmall
            color:            Theme.textSecondary
        }
    }
}