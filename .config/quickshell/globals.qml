pragma Singleton
import QtQuick 2.15
import Quickshell

QtObject {
    readonly property int workspaceNumber: 7

    property string activePanel    : ""
    property string lastPanel      : "cpu"


    property string activeCenterPanel : ""
    property string lastCenterPanel   : "dashboard"

    // Right-edge trifold (T.S.S) — which stack page is active
    property string activeEdgePanel : "wifi"   // "wifi" | "bluetooth" | "settings" | "notifications"
    property string lastEdgePanel   : "wifi"

    // Notification modes (mako)
    property bool notifSilent : false
    property bool notifDnd    : false

    // Screen capture — edge panel closes itself before launching tools
    property bool screenRecording : false

    // Cava desktop overlay (toggled from Media panel)
    property bool cavaOverlay : false
}