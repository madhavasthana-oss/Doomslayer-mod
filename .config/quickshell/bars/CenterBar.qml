import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.UPower
import QtQuick
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import "../utils"
import ".."

Item {
    id: centerBar
    width: Tokens.centerWidth
    height: Tokens.centerHeight

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

    property bool overrideActive: false
    property bool alertActive: false

    function pushStatus(msg, opts) {
        opts = opts || {}
        overrideActive = true
        alertActive = !!opts.alert
        messageAnimator.transitionTo(msg)
        overrideHoldTimer.interval = opts.holdMs || 4000
        overrideHoldTimer.restart()
    }

    Timer {
        id: overrideHoldTimer
        repeat: false
        onTriggered: {
            centerBar.overrideActive = false
            centerBar.alertActive = false
            messageTimer.pickAndShow()
            messageTimer.restart()
        }
    }

    AnimatedText {
        id: messageAnimator
        mode: AnimatedText.Mode.Scramble
    }

    Component.onCompleted: {
        messageAnimator.transitionTo(centerBar.statusMessages[0])
        centerBar.checkTimeOfDay()
        centerBar.initBatteryState()
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            timeText.text = Qt.formatDate(new Date(), "ddd") + " × " + Qt.formatDate(new Date(), "dd MMM") + " × " + Qt.formatTime(new Date(), "hh:mm")
            centerBar.checkTimeOfDay()
        }
    }

    Timer {
        id: messageTimer
        running: true
        repeat: true
        interval: 60000

        function pickAndShow() {
            let idx
            do {
                idx = Math.floor(Math.random() * centerBar.statusMessages.length)
            } while (idx === centerBar.lastMessageIndex && centerBar.statusMessages.length > 1)
            centerBar.lastMessageIndex = idx
            messageAnimator.transitionTo(centerBar.statusMessages[idx])
        }

        onTriggered: {
            if (centerBar.overrideActive)
                return
            pickAndShow()
        }
    }

    property var battery: UPower.displayDevice
    property bool batteryInitialized: false
    property bool wasOnAC: false          // true for Charging or FullyCharged
    property bool lowBatteryWarned: false
    property bool criticalBatteryWarned: false

    function initBatteryState() {
        if (!centerBar.battery || !centerBar.battery.ready)
            return
        const state = centerBar.battery.state
        centerBar.wasOnAC = (state === UPowerDeviceState.Charging || state === UPowerDeviceState.FullyCharged)
        centerBar.batteryInitialized = true
    }

    Connections {
        target: centerBar.battery

        function onReadyChanged() {
            if (centerBar.battery.ready && !centerBar.batteryInitialized)
                centerBar.initBatteryState()
        }

        function onStateChanged() {
            if (!centerBar.battery.ready)
                return

            if (!centerBar.batteryInitialized) {
                centerBar.initBatteryState()
                return
            }

            const state = centerBar.battery.state
            const nowOnAC = (state === UPowerDeviceState.Charging || state === UPowerDeviceState.FullyCharged)

            if (nowOnAC && !centerBar.wasOnAC) {
                centerBar.pushStatus("POWER CONDUIT ESTABLISHED: CHARGING", { holdMs: 4000 })
            } else if (!nowOnAC && centerBar.wasOnAC && state === UPowerDeviceState.Discharging) {
                centerBar.pushStatus("CHARGER DISCONNECTED: ON RESERVES", { holdMs: 4000 })
            } else if (state === UPowerDeviceState.FullyCharged) {
                centerBar.pushStatus("POWER CELL FULL", { holdMs: 4000 })
            }

            centerBar.wasOnAC = nowOnAC

            if (state === UPowerDeviceState.Charging) {
                centerBar.lowBatteryWarned = false
                centerBar.criticalBatteryWarned = false
            }
        }

        function onPercentageChanged() {
            if (!centerBar.battery.ready)
                return

            const pct = centerBar.battery.percentage * 100
            const discharging = centerBar.battery.state === UPowerDeviceState.Discharging

            if (discharging && pct <= 5 && !centerBar.criticalBatteryWarned) {
                centerBar.criticalBatteryWarned = true
                centerBar.pushStatus("CRITICAL: SEEK POWER SOURCE", { holdMs: 6000, alert: true })
            } else if (discharging && pct <= 15 && !centerBar.lowBatteryWarned) {
                centerBar.lowBatteryWarned = true
                centerBar.pushStatus("ARGENT ENERGY LOW", { holdMs: 5000, alert: true })
            }

            if (!discharging || pct > 20) {
                centerBar.lowBatteryWarned = false
                centerBar.criticalBatteryWarned = false
            }
        }
    }

    property string lastTimeGreetingDate: ""

    function checkTimeOfDay() {
        const now = new Date()
        const h = now.getHours()
        const dateStr = Qt.formatDate(now, "yyyy-MM-dd")

        let window = ""
        let msg = ""

        if (h >= 5 && h < 8) {
            window = "dawn"
            msg = "DAWN PATROL: RISE AND SLAY"
        } else if (h >= 8 && h < 12) {
            window = "morning"
            msg = "GOOD MORNING, SLAYER"
        } else if (h >= 17 && h < 21) {
            window = "evening"
            msg = "GOOD EVENING, STAY VIGILANT"
        } else if (h >= 0 && h < 5) {
            window = "night"
            msg = "NIGHT WATCH ACTIVE"
        } else {
            return
        }

        const guardKey = dateStr + "|" + window
        if (centerBar.lastTimeGreetingDate === guardKey)
            return

        centerBar.lastTimeGreetingDate = guardKey
        centerBar.pushStatus(msg, { holdMs: 5000 })
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
        barWidth:     Tokens.centerWidth
        barHeight:    Tokens.centerHeight
        alertActive:  centerBar.alertActive
        expanded:     Globals.activePanel !== ""
    }

    RowLayout {
        anchors.centerIn: parent
        spacing: Tokens.spacingMd
        ColumnLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: Tokens.spacingXss
            Text {
                Layout.preferredWidth: Tokens.greetingWidth
                text: "<< " + messageAnimator.displayedText + " >>"
                horizontalAlignment: Text.AlignHCenter
                font.family: kogni.name
                font.pixelSize: Tokens.fontSizeMedium
                color: Theme.textPrimary
            }
            Text {
                Layout.preferredWidth: Tokens.greetingWidth
                id: timeText
                Layout.alignment: Qt.AlignHCenter
                text: Qt.formatDate(new Date(), "ddd") + " × " + Qt.formatDate(new Date(), "dd MMM") + " × " + Qt.formatTime(new Date(), "hh:mm")
                horizontalAlignment: Text.AlignHCenter
                font.family: jetbrains.name
                font.pixelSize: Tokens.fontSizeSmall
                color: Theme.textSecondary
            }
        }
    }
       MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor

            onClicked: {
                if (Globals.activeCenterPanel !== "") {
                    Globals.lastCenterPanel = Globals.activeCenterPanel;
                    Globals.activeCenterPanel = "";
                } else
                    Globals.activeCenterPanel = Globals.lastCenterPanel; 
            }
        }
}
