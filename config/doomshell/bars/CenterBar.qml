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
    property var statusMessages: [
    "THE ONLY THING THEY FEAR IS YOU",
    "RIP AND TEAR",
    "MISSION ACTIVE",
    "COMBAT READY",
    "SLAYER ONLINE",
    "THREAT LEVEL: NOMINAL",
    "UAC NETWORK STABLE",
    "BFG DIVISION",
    "ALL SYSTEMS GREEN",
    "NO DEMONIC ACTIVITY DETECTED",
    "ARGENT ENERGY CONTAINED"
        ]
    property int lastMessageIndex: 0
    AnimatedText {
        id: messageAnimator
        mode: AnimatedText.Mode.Scramble
        }
    Component.onCompleted: {
        console.log("CENTERBAR CREATED")
        messageAnimator.transitionTo(centerBar.statusMessages[0])
        }
    Component.onDestruction: {
            console.log("CENTERBAR DESTROYED")
        }
    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
        timeText.text = Qt.formatDate(new Date(), "ddd")    + 
        " × " + Qt.formatDate(new Date(), "dd MMM") + 
        " × " + Qt.formatTime(new Date(), "hh:mm")
            }
        }
    // Picks the next message and kicks off the type-out phase
    Timer {
        id: messageTimer
        running: true
        repeat: true
        interval: 60000
        onTriggered: {
        let idx
        do  {
                idx = Math.floor(
                Math.random()
                * centerBar.statusMessages.length
            )
        } while (
            idx === centerBar.lastMessageIndex
            && centerBar.statusMessages.length > 1
                    )
            centerBar.lastMessageIndex = idx
                messageAnimator.transitionTo(
                centerBar.statusMessages[idx]
            )
        }
    }

        
    FontLoader {
        id: kogni
        source: "../assets/fonts/KogniGear.ttf"
        }
    FontLoader {
        id: jetbrains
        source: "../assets/fonts/JetBrainsMonoNerdFontMono-Regular.ttf"
        }
    CenterTrapezoid {
        anchors.fill: parent
        barWidth:     Globals.centerWidth
        barHeight:    Globals.centerHeight
        alertActive:  false
        expanded:     Globals.activePanel !== ""
    }
        RowLayout {
            anchors.centerIn: parent
            spacing: 12
            ColumnLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 1
        Text {
            Layout.preferredWidth: Globals.greetingWidth
            text: "<< " + messageAnimator.displayedText + " >>"
            horizontalAlignment: Text.AlignHCenter
            font.family: kogni.name
            font.pixelSize: Theme.fontSizeMedium
            color: Theme.textPrimary
    }
        Text {
            Layout.preferredWidth: Globals.greetingWidth
            id: timeText
            Layout.alignment: Qt.AlignHCenter
            text: Qt.formatDate(new Date(), "ddd") + " × " + Qt.formatDate(new Date(), "dd MMM") + " × " + Qt.formatTime(new Date(), "hh:mm")
            horizontalAlignment: Text.AlignHCenter
            font.family: jetbrains.name
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.textSecondary
    }
}
    }
}