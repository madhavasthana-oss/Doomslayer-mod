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
    width:  Globals.leftWidth
    height: Globals.leftHeight

    Timer {
        id: clockTimer
        interval: 1000
        running:  true
        repeat:   true
        onTriggered: timeText.text = Qt.formatTime(new Date(), "hh:mm")
    }
    // ---------------------------------------------------------
    //  FONT
    // ---------------------------------------------------------

    FontLoader {
        id: kogni
        source: "../assets/fonts/KogniGear.ttf"
    }

    // ---------------------------------------------------------
    //  SHAPE
    // ---------------------------------------------------------

    leftTrapezoid {
        anchors.fill: parent
        barWidth:     Globals.leftWidth
        barHeight:    Globals.leftHeight
        alertActive:  false
    }

    // ---------------------------------------------------------
    //  CONTENT
    // ---------------------------------------------------------

    Column {
        anchors.centerIn       : parent
        spacing                : 2   
        
        Text {
            anchors.horizontalCenter: parent.horizaontalleft
            // hortizontalAlignment    : Text.AlignHleft
            text                    : "Greetings, Slayer"
            font.family             : kogni.name
            font.pixelSize          : Theme.fontSizeMedium
            color                   : Theme.textPrimary
        }
        
        Text {
            anchors.horizontalCenter: parent.horizontalleft
            // hortizontalAlignment    : Text.AlignHleft
            text                    : Qt.formatTime(new Date(), "hh:mm")
            font.family             : kogni.name
            font.pixelSize          : Theme.fontSizeSmall
            color                   : Theme.textSecondary
        }
    }
}