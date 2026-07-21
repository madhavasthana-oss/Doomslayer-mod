// BluetoothBackend.qml — Quickshell.Bluetooth + bluetoothctl fallbacks
import QtQuick
import Quickshell
import Quickshell.Bluetooth
import Quickshell.Io
import "../../.."

Item {
    id: root

    property bool powered: Bluetooth.defaultAdapter ? Bluetooth.defaultAdapter.enabled : false
    property bool discovering: Bluetooth.defaultAdapter ? Bluetooth.defaultAdapter.discovering : false
    property string statusMsg: ""
    property var adapter: Bluetooth.defaultAdapter

    readonly property var devices: Bluetooth.devices

    function setPowered(on) {
        if (!Bluetooth.defaultAdapter)
            return
        Bluetooth.defaultAdapter.enabled = on
        root.statusMsg = on ? "ADAPTER ONLINE" : "ADAPTER OFFLINE"
    }

    function setDiscovering(on) {
        if (!Bluetooth.defaultAdapter)
            return
        Bluetooth.defaultAdapter.discovering = on
        root.statusMsg = on ? "SCANNING AIRSPACE..." : "SCAN HALTED"
    }

    function toggleDiscover() {
        setDiscovering(!root.discovering)
    }

    function connectDevice(dev) {
        if (!dev)
            return
        root.statusMsg = "LINKING " + (dev.name || dev.deviceName || dev.address)
        if (dev.paired || dev.bonded) {
            dev.connect()
        } else {
            dev.pair()
            // connect after pair — device signals will update UI
            pairThenConnect.target = dev
        }
    }

    function disconnectDevice(dev) {
        if (!dev)
            return
        dev.disconnect()
        root.statusMsg = "DROPPED " + (dev.name || dev.address)
    }

    function forgetDevice(dev) {
        if (!dev)
            return
        dev.forget()
        root.statusMsg = "FORGOT " + (dev.name || dev.address)
    }

    Connections {
        id: pairThenConnect
        target: null
        ignoreUnknownSignals: true
        function onPairedChanged() {
            if (target && target.paired)
                target.connect()
        }
        function onConnectedChanged() {
            if (target && target.connected)
                root.statusMsg = "LINKED"
        }
    }

    Connections {
        target: Bluetooth
        function onDefaultAdapterChanged() {
            root.statusMsg = Bluetooth.defaultAdapter ? "ADAPTER READY" : "NO ADAPTER"
        }
    }
}
