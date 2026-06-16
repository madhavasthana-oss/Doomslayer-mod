import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import "../utils"
import ".."

Item {
    id: centerBar
    width:  Globals.centerWidth
    height: Globals.centerHeight
    
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
    }

    // ---------------------------------------------------------
    //  CONTENT
    //  GridLayout — 5 columns, 2 rows
    //  Row 0: labels — CPU  GPU  Greetings  RAM  BAT
    //  Row 1: values — X%   Y%   23:52      Z%   W%
    // ---------------------------------------------------------

    GridLayout {
        anchors.centerIn: parent
        columns:          5
        rows:             2
        rowSpacing:       2
        columnSpacing:    60

        // ── ROW 0 — labels ──────────────────────────────────

        Text {
            Layout.alignment: Qt.AlignHCenter
            text:             "CPU"
            font.family:      kogni.name
            font.pixelSize:   Theme.fontSizeBase
            color:            Theme.textMuted
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
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
            Layout.alignment: Qt.AlignHCenter
            text:             "BAT"
            font.family:      kogni.name
            font.pixelSize:   Theme.fontSizeBase
            color:            Theme.textMuted
        }

        // ── ROW 1 — values ──────────────────────────────────

        Text {
            Layout.alignment: Qt.AlignHCenter
            text:             "X %"
            font.family:      kogni.name
            font.pixelSize:   Theme.fontSizeSmall
            color:            Theme.textSecondary
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            text:             "Y %"
            font.family:      kogni.name
            font.pixelSize:   Theme.fontSizeSmall
            color:            Theme.textSecondary
        }

        Text {
            id:               timeText
            Layout.alignment: Qt.AlignHCenter
            text:             Qt.formatTime(new Date(), "hh:mm")
            font.family:      kogni.name
            font.pixelSize:   Theme.fontSizeSmall
            color:            Theme.textSecondary
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            text:             "Z %"
            font.family:      kogni.name
            font.pixelSize:   Theme.fontSizeSmall
            color:            Theme.textSecondary
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            text:             "W %"
            font.family:      kogni.name
            font.pixelSize:   Theme.fontSizeSmall
            color:            Theme.textSecondary
        }
    }
}