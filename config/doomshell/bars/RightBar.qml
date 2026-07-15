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
import "../widgets/rightBarWidgets/system/CPU"
import "../widgets/rightBarWidgets/system/GPU"
import "../widgets/rightBarWidgets/system/RAM"

Item {
    id: rightBar
    width: Tokens.rightWidth
    height: Tokens.rightHeight

    // ---------------------------------------------------------
    //  GRADIENT HELPER
    // ---------------------------------------------------------
    // Blends from color1 -> color2 as alpha goes 0 -> 1.
    // Callers must pass alpha such that alpha=1 means "critical".

    function __gradient__(color1, color2, alpha) {
        color1 = color1.toString();
        color2 = color2.toString();
        let r1 = parseInt(color1.slice(1, 3), 16);
        let g1 = parseInt(color1.slice(3, 5), 16);
        let b1 = parseInt(color1.slice(5, 7), 16);
        let r2 = parseInt(color2.slice(1, 3), 16);
        let g2 = parseInt(color2.slice(3, 5), 16);
        let b2 = parseInt(color2.slice(5, 7), 16);
        return "#" + Math.round((1 - alpha) * r1 + alpha * r2).toString(16).padStart(2, "0") + Math.round((1 - alpha) * g1 + alpha * g2).toString(16).padStart(2, "0") + Math.round((1 - alpha) * b1 + alpha * b2).toString(16).padStart(2, "0");
    }

    // ---------------------------------------------------------
    //  GiB FORMAT HELPER
    // ---------------------------------------------------------
    // RAMBackend already computes __ram_in_use__ / __ram_total__ in GiB
    // (kB from /proc/meminfo divided by 1024**2), so we just format here.

    function __fmtGiB__(value) {
        return Number(value).toFixed(2);
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
    //  STAT LOADERS
    // ---------------------------------------------------------

    BATStats {
        id: batStat
        visible: false
        anchors.top: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        onReady: {
            batLabel.opacity = 1;
            batPercent.opacity = 1;
            constBatBar.opacity = 1;
            varBatBar.opacity = 1;
        }
    }

    Volume {
        id: audioStat
        visible: false
        anchors.top: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        onReady: {
            volLabel.opacity = 1;
            volPercent.opacity = 1;
            constVolBar.opacity = 1;
            varVolBar.opacity = 1;
        }
    }

    CPUBackend {
        id: cpuStat
        visible: false
        anchors.top: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter

        readonly property int averageUsage: {
            if (!__ready__ || cores.count === 0)
                return -1;
            let sum = 0;
            let counted = 0;
            for (let i = 0; i < cores.count; i++) {
                let u = cores.get(i).usage;
                if (u !== -1 && u !== undefined) {
                    sum += u;
                    counted++;
                }
            }
            return counted > 0 ? Math.round(sum / counted) : -1;
        }

        // __ready__ is a plain property on CPUBackend, not a signal —
        // QML's auto-generated changed-signal preserves the literal
        // property name (including underscores): on__Ready__Changed.
        on__Ready__Changed: {
            if (__ready__) {
                cpuLabel.opacity = 1;
                cpuPercent.opacity = 1;
                constCpuBar.opacity = 1;
                varCpuBar.opacity = 1;
            }
        }
    }

    GPUBackend {
        id: gpuStat
        visible: false
        anchors.top: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter

        // __is_ready__ is a plain property on GPUBackend, not a signal —
        // same rule: on__Is_ready__Changed, not onIsReadyChanged.
        on__Is_ready__Changed: {
            if (__is_ready__) {
                gpuLabel.opacity = 1;
                gpuPercent.opacity = 1;
                constGpuBar.opacity = 1;
                varGpuBar.opacity = 1;
            }
        }
    }

    RAMBackend {
        id: ramStat
        visible: false
        anchors.top: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter

        readonly property string usageGiB: {
            if (__ram_total__ < 0 || __ram_in_use__ < 0)
                return "--/--";
            return __fmtGiB__(__ram_in_use__) + "/" + __fmtGiB__(__ram_total__) + " GiB";
        }

        // __is_ready__ is a plain property on RAMBackend, not a signal —
        // same rule: on__Is_ready__Changed, not onIsReadyChanged.
        on__Is_ready__Changed: {
            if (__is_ready__) {
                ramLabel.opacity = 1;
                ramValue.opacity = 1;
            }
        }
    }

    // ---------------------------------------------------------
    //  SHAPE
    // ---------------------------------------------------------

    RightTrapezoid {
        anchors.fill: parent
        barWidth: Tokens.rightWidth
        barHeight: Tokens.rightHeight
        alertActive: false
    }

    // ---------------------------------------------------------
    //  CONTENT ROW
    // ---------------------------------------------------------

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Tokens.rightHeight + Tokens.inMostSpacing
        anchors.rightMargin: Tokens.inMostSpacing
        spacing: Tokens.inMostSpacing

        // ---------------------------------------------------------
        //  ZONE 1 — Battery + Volume
        // ---------------------------------------------------------

        GridLayout {
            columns: 3
            rows: 2
            rowSpacing: 2
            columnSpacing: 4
            Layout.alignment: Qt.AlignHCenter
            Layout.fillWidth: false

            // BAT label
            Text {
                id: batLabel
                text: "BAT"
                font.family: kogni.name
                font.pixelSize: Tokens.fontSizeLabel
                color: Theme.textMuted
                opacity: 0
                Behavior on opacity {
                    NumberAnimation {
                        duration: Globals.activeWindowAndBatteryAndVolumeAnim
                        easing.type: Easing.OutCubic
                    }
                }
            }

            // BAT percentage
            Text {
                id: batPercent
                text: batStat.percentage + "%"
                font.family: jetbrains.name
                font.pixelSize: Tokens.fontSizeLabel
                color: Theme.textSecondary
                opacity: 0
                Behavior on opacity {
                    NumberAnimation {
                        duration: Globals.activeWindowAndBatteryAndVolumeAnim
                        easing.type: Easing.OutCubic
                    }
                }
            }

            // BAT bar
            Rectangle {
                id: constBatBar
                Layout.preferredWidth: 50
                Layout.preferredHeight: 4
                color: Theme.bgElevated
                radius: 25
                opacity: 0
                Behavior on opacity {
                    NumberAnimation {
                        duration: Globals.activeWindowAndBatteryAndVolumeAnim
                        easing.type: Easing.OutCubic
                    }
                }
                Rectangle {
                    id: varBatBar
                    width: parent.width * batStat.percentage * 0.01
                    height: parent.height
                    // Low battery = critical: invert percentage before feeding gradient.
                    color: __gradient__(Theme.stateSafe, Theme.stateCritical, 1.00 - (batStat.percentage / 100))
                    radius: 25
                    opacity: 0
                    Behavior on opacity {
                        NumberAnimation {
                            duration: Globals.activeWindowAndBatteryAndVolumeAnim
                            easing.type: Easing.OutCubic
                        }
                    }
                }
            }

            // VOL label
            Text {
                id: volLabel
                text: "VOL"
                font.family: kogni.name
                font.pixelSize: Tokens.fontSizeLabel
                color: Theme.textMuted
                opacity: 0
                Behavior on opacity {
                    NumberAnimation {
                        duration: Globals.activeWindowAndBatteryAndVolumeAnim
                        easing.type: Easing.OutCubic
                    }
                }
            }

            // VOL percentage
            Text {
                id: volPercent
                text: audioStat.muted ? "M" : audioStat.volume + "%"
                font.family: jetbrains.name
                font.pixelSize: Tokens.fontSizeLabel
                color: audioStat.muted ? Theme.textMuted : Theme.textSecondary
                opacity: 0
                Behavior on opacity {
                    NumberAnimation {
                        duration: Globals.activeWindowAndBatteryAndVolumeAnim
                        easing.type: Easing.OutCubic
                    }
                }
                Behavior on color {
                    ColorAnimation {
                        duration: 120
                        easing.type: Easing.OutCubic
                    }
                }
            }

            // VOL bar
            Rectangle {
                id: constVolBar
                implicitWidth: 50
                implicitHeight: 4
                color: Theme.bgElevated
                radius: 25
                opacity: 0
                Behavior on opacity {
                    NumberAnimation {
                        duration: Globals.activeWindowAndBatteryAndVolumeAnim
                        easing.type: Easing.OutCubic
                    }
                }
                Rectangle {
                    id: varVolBar
                    width: parent.width * audioStat.volume / 100
                    height: parent.height
                    color: audioStat.muted ? Theme.bgElevated : Theme.accent
                    radius: 25
                    opacity: 0
                    Behavior on opacity {
                        NumberAnimation {
                            duration: Globals.activeWindowAndBatteryAndVolumeAnim
                            easing.type: Easing.OutCubic
                        }
                    }
                    Behavior on color {
                        ColorAnimation {
                            duration: 120
                            easing.type: Easing.OutCubic
                        }
                    }
                }
            }
        }

        Item {
            Layout.fillWidth: true
        }

        // ---------------------------------------------------------
        //  ZONE 2 — CPU + GPU (bar style, matches BAT/VOL)
        // ---------------------------------------------------------

        GridLayout {
            columns: 3
            rows: 2
            rowSpacing: 2
            columnSpacing: 4
            Layout.alignment: Qt.AlignHCenter
            Layout.fillWidth: false

            // CPU label
            Text {
                id: cpuLabel
                text: "CPU"
                font.family: kogni.name
                font.pixelSize: Tokens.fontSizeLabel
                color: Theme.textMuted
                opacity: 0
                Behavior on opacity {
                    NumberAnimation {
                        duration: Globals.activeWindowAndBatteryAndVolumeAnim
                        easing.type: Easing.OutCubic
                    }
                }
            }

            // CPU percentage
            Text {
                id: cpuPercent
                text: cpuStat.averageUsage >= 0 ? cpuStat.averageUsage + "%" : "--%"
                font.family: jetbrains.name
                font.pixelSize: Tokens.fontSizeLabel
                color: Theme.textSecondary
                opacity: 0
                Behavior on opacity {
                    NumberAnimation {
                        duration: Globals.activeWindowAndBatteryAndVolumeAnim
                        easing.type: Easing.OutCubic
                    }
                }
            }

            // CPU bar
            Rectangle {
                id: constCpuBar
                Layout.preferredWidth: 50
                Layout.preferredHeight: 4
                color: Theme.bgElevated
                radius: 25
                opacity: 0
                Behavior on opacity {
                    NumberAnimation {
                        duration: Globals.activeWindowAndBatteryAndVolumeAnim
                        easing.type: Easing.OutCubic
                    }
                }
                Rectangle {
                    id: varCpuBar
                    width: parent.width * Math.max(cpuStat.averageUsage, 0) * 0.01
                    height: parent.height
                    // High usage = critical: feed percentage directly, no inversion.
                    color: __gradient__(Theme.stateSafe, Theme.stateCritical, Math.max(cpuStat.averageUsage, 0) / 100)
                    radius: 25
                    opacity: 0
                    Behavior on opacity {
                        NumberAnimation {
                            duration: Globals.activeWindowAndBatteryAndVolumeAnim
                            easing.type: Easing.OutCubic
                        }
                    }
                }
            }

            // GPU label
            Text {
                id: gpuLabel
                text: "GPU"
                font.family: kogni.name
                font.pixelSize: Tokens.fontSizeLabel
                color: Theme.textMuted
                opacity: 0
                Behavior on opacity {
                    NumberAnimation {
                        duration: Globals.activeWindowAndBatteryAndVolumeAnim
                        easing.type: Easing.OutCubic
                    }
                }
            }

            // GPU percentage
            Text {
                id: gpuPercent
                text: gpuStat.__gpu_usage__ >= 0 ? gpuStat.__gpu_usage__ + "%" : "--%"
                font.family: jetbrains.name
                font.pixelSize: Tokens.fontSizeLabel
                color: Theme.textSecondary
                opacity: 0
                Behavior on opacity {
                    NumberAnimation {
                        duration: Globals.activeWindowAndBatteryAndVolumeAnim
                        easing.type: Easing.OutCubic
                    }
                }
            }

            // GPU bar
            Rectangle {
                id: constGpuBar
                implicitWidth: 50
                implicitHeight: 4
                color: Theme.bgElevated
                radius: 25
                opacity: 0
                Behavior on opacity {
                    NumberAnimation {
                        duration: Globals.activeWindowAndBatteryAndVolumeAnim
                        easing.type: Easing.OutCubic
                    }
                }
                Rectangle {
                    id: varGpuBar
                    width: parent.width * Math.max(gpuStat.__gpu_usage__, 0) / 100
                    height: parent.height
                    // High usage = critical: feed percentage directly, no inversion.
                    color: __gradient__(Theme.stateSafe, Theme.stateCritical, Math.max(gpuStat.__gpu_usage__, 0) / 100)
                    radius: 25
                    opacity: 0
                    Behavior on opacity {
                        NumberAnimation {
                            duration: Globals.activeWindowAndBatteryAndVolumeAnim
                            easing.type: Easing.OutCubic
                        }
                    }
                }
            }
        }

        Item {
            Layout.fillWidth: true
        }

        // ---------------------------------------------------------
        //  ZONE 3 — RAM
        // ---------------------------------------------------------

        ColumnLayout {
            id: sysGrid
            Layout.alignment: parent.verticalCenter
            spacing: 1
            // Row 1 — labels
            Text {
                id: ramLabel
                Layout.alignment: Qt.AlignHCenter
                text: "RAM"
                horizontalAlignment: Text.AlignHCenter
                font.family: kogni.name
                font.pixelSize: Tokens.fontSizeBase
                color: Theme.textMuted
                opacity: 0
                Behavior on opacity {
                    NumberAnimation {
                        duration: Globals.activeWindowAndBatteryAndVolumeAnim
                        easing.type: Easing.OutCubic
                    }
                }
            }

            // Row 2 — live values
            Text {
                id: ramValue
                Layout.alignment: Qt.AlignHCenter
                text: ramStat.usageGiB
                horizontalAlignment: Text.AlignHCenter
                font.family: jetbrains.name
                font.pixelSize: Tokens.fontSizeLabel
                color: Theme.textSecondary
                opacity: 0
                Behavior on opacity {
                    NumberAnimation {
                        duration: Globals.activeWindowAndBatteryAndVolumeAnim
                        easing.type: Easing.OutCubic
                    }
                }
            }
        }
    }
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor

            onClicked: {
                if (Globals.activePanel !== "") {
                    Globals.lastPanel = Globals.activePanel;
                    Globals.activePanel = "";
                } else
                    Globals.activePanel = Globals.lastPanel;
            }
        }
}
