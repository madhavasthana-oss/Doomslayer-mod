import Quickshell.Services.UPower
import QtQuick

Item {
    id: batteryStats

    property int percentage: 0
    property string state: ""
    property string timeRemaining: ""

    Connections {
        target: UPower.displayDevice

        function onPercentageChanged() {
            batteryStats.percentage = Math.round(UPower.displayDevice.percentage * 100)
        }

        function onStateChanged() {
            batteryStats.state = UPower.displayDevice.state
        }

        function onTimeToEmptyChanged() {
            batteryStats.timeRemaining = UPower.displayDevice.timeToEmpty
        }

        function onTimeToFullChanged() {
            batteryStats.timeRemaining = UPower.displayDevice.timeToFull
        }
    }

    Component.onCompleted: {
        percentage = Math.round(UPower.displayDevice.percentage * 100)
        state = UPower.displayDevice.state
        timeRemaining = UPower.displayDevice.timeToEmpty > 0
            ? UPower.displayDevice.timeToEmpty
            : UPower.displayDevice.timeToFull
    }
}