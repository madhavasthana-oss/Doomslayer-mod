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
    // Hug content width so Bar can center this section; text elides inside
    implicitWidth: Math.min(
        Tokens.centerWidth,
        Math.max(Tokens.greetingWidth * 2, statusText.implicitWidth + Tokens.spacingMd * 2)
    )
    implicitHeight: Tokens.centerHeight
    clip: true

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

    // Prefer UPower.onBattery for plug/unplug: with charge thresholds enabled,
    // displayDevice.state is often PendingCharge (not Charging) while AC is connected,
    // so state-based AC detection never flips and status messages never fire.
    property var battery: UPower.displayDevice
    property bool batteryInitialized: false
    property bool wasOnAC: false
    property int lastBatteryState: UPowerDeviceState.Unknown
    property bool lowBatteryWarned: false
    property bool criticalBatteryWarned: false

    function initBatteryState() {
        // onBattery is valid even before displayDevice.ready
        centerBar.wasOnAC = !UPower.onBattery
        if (centerBar.battery && centerBar.battery.ready)
            centerBar.lastBatteryState = centerBar.battery.state
        centerBar.batteryInitialized = true
    }

    // Plug / unplug — system AC line, not device charge state
    Connections {
        target: UPower

        function onOnBatteryChanged() {
            if (!centerBar.batteryInitialized) {
                centerBar.initBatteryState()
                return
            }

            const nowOnAC = !UPower.onBattery
            if (nowOnAC === centerBar.wasOnAC)
                return

            if (nowOnAC) {
                centerBar.pushStatus("POWER CONDUIT ESTABLISHED: CHARGING", { holdMs: 4000 })
                centerBar.lowBatteryWarned = false
                centerBar.criticalBatteryWarned = false
            } else {
                centerBar.pushStatus("CHARGER DISCONNECTED: ON RESERVES", { holdMs: 4000 })
            }

            centerBar.wasOnAC = nowOnAC
        }
    }

    Connections {
        target: UPower.displayDevice

        function onReadyChanged() {
            if (UPower.displayDevice.ready && !centerBar.batteryInitialized)
                centerBar.initBatteryState()
            else if (UPower.displayDevice.ready)
                centerBar.lastBatteryState = UPower.displayDevice.state
        }

        function onStateChanged() {
            if (!UPower.displayDevice.ready)
                return

            if (!centerBar.batteryInitialized) {
                centerBar.initBatteryState()
                return
            }

            const state = UPower.displayDevice.state
            const prev = centerBar.lastBatteryState

            // Only a completed charge cycle: Charging → FullyCharged.
            // Do NOT treat PendingCharge as full — with charge thresholds that
            // state means "plugged in, not charging yet", and brief
            // Charging→PendingCharge blips on plug-in were false positives.
            if (state === UPowerDeviceState.FullyCharged
                && prev === UPowerDeviceState.Charging) {
                centerBar.pushStatus("POWER CELL FULL", { holdMs: 4000 })
            }

            if (state === UPowerDeviceState.Charging
                || state === UPowerDeviceState.FullyCharged
                || state === UPowerDeviceState.PendingCharge) {
                centerBar.lowBatteryWarned = false
                centerBar.criticalBatteryWarned = false
            }

            centerBar.lastBatteryState = state
        }

        function onPercentageChanged() {
            if (!UPower.displayDevice.ready)
                return

            const pct = UPower.displayDevice.percentage * 100
            const discharging = UPower.onBattery
                || UPower.displayDevice.state === UPowerDeviceState.Discharging

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

    ColumnLayout {
        anchors.fill: parent
        anchors.leftMargin: Tokens.spacingXs
        anchors.rightMargin: Tokens.spacingXs
        spacing: Tokens.spacingXss

        Text {
            id: statusText
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            Layout.minimumWidth: 0
            text: "<< " + messageAnimator.displayedText + " >>"
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideMiddle
            maximumLineCount: 1
            wrapMode: Text.NoWrap
            clip: true
            font.family: Theme.fontDisplay
            font.pixelSize: Tokens.fontSizeMedium
            color: Theme.textPrimary
        }
        Text {
            id: timeText
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            Layout.minimumWidth: 0
            text: Qt.formatDate(new Date(), "ddd") + " × " + Qt.formatDate(new Date(), "dd MMM") + " × " + Qt.formatTime(new Date(), "hh:mm")
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
            maximumLineCount: 1
            wrapMode: Text.NoWrap
            clip: true
            font.family: Theme.fontMono
            font.pixelSize: Tokens.fontSizeSmall
            color: Theme.textSecondary
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        // Let status text show through; only need the click
        propagateComposedEvents: true

        onClicked: {
            if (Globals.activeCenterPanel !== "") {
                Globals.lastCenterPanel = Globals.activeCenterPanel
                Globals.activeCenterPanel = ""
            } else {
                Globals.activeCenterPanel = Globals.lastCenterPanel
            }
        }
    }
}
