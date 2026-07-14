pragma Singleton
import QtQuick 2.15
import Quickshell

QtObject {

    // =========================================================
    //  SCREEN-AWARE SCALING
    //  Fixed: no longer floors at 1x (screens smaller than 1920
    //  wide now actually scale down). Fixed: now accounts for
    //  height too, not just width, so short-but-wide screens
    //  don't get an inflated scale factor from width alone.
    // =========================================================
    readonly property var primaryScreen: Quickshell.screens.length > 0 ? Quickshell.screens[0] : null

    readonly property real widthRatio:  primaryScreen ? primaryScreen.width  / 1920 : 1.0
    readonly property real heightRatio: primaryScreen ? primaryScreen.height / 1080 : 1.0

    // Baseline is 1920x1080. Scale is the smaller of the two ratios so we
    // never overflow in either dimension, clamped to a sane visual range.
    readonly property real scaleFactor: primaryScreen ?
        Math.max(0.65, Math.min(1.45, Math.min(widthRatio, heightRatio))) : 1.0

    readonly property real dpiScale: primaryScreen ? primaryScreen.devicePixelRatio : 1.0

    // =========================================================
    //  DOOMSHELL — GLOBALS SINGLETON
    //  Pure app state + screen detection only. Every pixel value
    //  that used to live here has moved to Tokens.qml.
    // =========================================================

    readonly property int workspaceNumber: 7

    // Active panel tracker — single source of truth
    // Values: "" | "cpu" | "gpu" | "ram" | "bat" | "greeting"
    property string activePanel    : ""
    property string lastPanel      : "cpu"
    property bool consolePanelOpen : false
}