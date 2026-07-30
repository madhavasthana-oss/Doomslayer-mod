pragma Singleton
import QtQuick 2.15
import Quickshell

QtObject {
    readonly property int workspaceNumber: 7

    property string activePanel    : ""
    property string lastPanel      : "cpu"


    property string activeCenterPanel : ""
    property string lastCenterPanel   : "dashboard"

    // Right-edge trifold (T.S.S) --- which stack page is active
    property string activeEdgePanel : "wifi"   // "wifi" | "bluetooth" | "settings" | "notifications"
    property string lastEdgePanel   : "wifi"

    // Notification modes (mako)
    property bool notifSilent : false
    property bool notifDnd    : false

    // Screen capture --- edge panel closes itself before launching tools
    property bool screenRecording : false

    // Cava desktop overlay (toggled from Media panel)
    property bool cavaOverlay : false

    // Last toast summary (debug breadcrumb; not an event bus)
    property string lastAction : ""

    // Fire a mako toast via notify-send. Empty summary = no-op.
    // appName becomes notify-send -a (mako criteria), not "mako".
    function toast(summary, body, appName) {
        if (summary === undefined || summary === null)
            return
        const sum = String(summary).trim()
        if (!sum.length)
            return

        const app = (appName !== undefined && appName !== null && String(appName).length)
            ? String(appName)
            : "Quickshell"
        const bod = (body !== undefined && body !== null) ? String(body) : ""

        const args = [
            "notify-send",
            "-a", app,
            "-u", "low",
            "-t", "4000",
            sum
        ]
        if (bod.length)
            args.push(bod)

        lastAction = sum
        Quickshell.execDetached(args)
    }
}