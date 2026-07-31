pragma Singleton
import QtQuick 2.15
import Quickshell
import Quickshell.Io

// Singleton (not QtObject): FileView must be a child object; QtObject has no
// default property and fails with "Cannot assign to non-existent default property".
Singleton {
    id: root

    // ---
    //  Live palette file (written by load-legacy-colors.sh / load-wallust-colors.sh)
    //  Switch sources without regenerating this QML file.
    // ---
    readonly property string colorsPath: Quickshell.shellDir + "/colors/active-colors.json"

    // Hardcoded Doom fallbacks — used until JSON loads, or if a key is missing.
    readonly property var _defaults: ({
        "bgPrimary":     "#0D0000",
        "bgSurface":     "#1A0000",
        "bgElevated":    "#2A0500",
        "accent":        "#FF4500",
        "accentWarm":    "#FFCA80",
        "accentSoft":    "#FF80BF",
        "textPrimary":   "#FF4500",
        "textSecondary": "#FFCA80",
        "textMuted":     "#CC2200",
        "textDim":       "#601000",
        "stateCritical": "#CC2200",
        "stateSafe":     "#8AFF80",
        "stateWarning":  "#FFCA80",
        "borderActive":  "#FF4500",
        "borderIdle":    "#CC2200",
        "bgConsole":     "#1F0200",
        "borderConsole": "#CC2200",
        "glowConsole":   "#994400"
    })

    property var _palette: _defaults
    property string colorsSource: "defaults"

    function _hexOf(key) {
        const p = _palette
        if (p && p[key] !== undefined && p[key] !== null && String(p[key]).length)
            return String(p[key])
        return String(_defaults[key])
    }

    function _applyJsonText(text) {
        if (text === undefined || text === null)
            return
        const raw = String(text).trim()
        if (!raw.length)
            return
        try {
            const data = JSON.parse(raw)
            const next = Object.assign({}, _defaults)
            for (const key in _defaults) {
                if (data[key] !== undefined && data[key] !== null && String(data[key]).length)
                    next[key] = String(data[key])
            }
            _palette = next
            colorsSource = (data._source !== undefined && String(data._source).length)
                ? String(data._source)
                : "active"
        } catch (e) {
            console.warn("Theme: failed to parse colors JSON:", e)
        }
    }

    FileView {
        id: colorsFile
        path: root.colorsPath
        watchChanges: true
        blockLoading: true

        onFileChanged: reload()
        onLoaded: root._applyJsonText(text())
        Component.onCompleted: {
            // text() is available after initial load when blockLoading is true
            try {
                root._applyJsonText(text())
            } catch (e) {
                // keep _defaults
            }
        }
    }

    // Backgrounds
    readonly property color bgPrimary:   root._hexOf("bgPrimary")
    readonly property color bgSurface:   root._hexOf("bgSurface")
    readonly property color bgElevated:  root._hexOf("bgElevated")

    // Core accents
    readonly property color accent:      root._hexOf("accent")
    readonly property color accentWarm:  root._hexOf("accentWarm")
    readonly property color accentSoft:  root._hexOf("accentSoft")

    // Text
    readonly property color textPrimary:   root._hexOf("textPrimary")
    readonly property color textSecondary: root._hexOf("textSecondary")
    readonly property color textMuted:     root._hexOf("textMuted")
    readonly property color textDim:       root._hexOf("textDim")

    // State colors
    readonly property color stateCritical: root._hexOf("stateCritical")
    readonly property color stateSafe:     root._hexOf("stateSafe")
    readonly property color stateWarning:  root._hexOf("stateWarning")

    // Border / stroke color (widths now live in Tokens)
    readonly property color borderActive:  root._hexOf("borderActive")
    readonly property color borderIdle:    root._hexOf("borderIdle")

    // Expansion panel visuals
    readonly property color bgConsole:     root._hexOf("bgConsole")
    readonly property color borderConsole: root._hexOf("borderConsole")
    readonly property color glowConsole:   root._hexOf("glowConsole")

    // SYSTEM ICONS --- breeze symbolic, tinted at use site to theme colors
    readonly property string iconThemeActions: "file:///usr/share/icons/breeze/actions/22/"
    readonly property string iconPoweroff: iconThemeActions + "system-shutdown-symbolic.svg"
    readonly property string iconReboot:   iconThemeActions + "system-reboot-symbolic.svg"
    readonly property string iconLogout:   iconThemeActions + "system-log-out-symbolic.svg"
    readonly property string iconSleep:    iconThemeActions + "system-suspend-symbolic.svg"
    readonly property string iconLock:     iconThemeActions + "system-lock-screen-symbolic.svg"

    // Edge panel tiles --- full file URIs (icons live in actions/status/devices)
    readonly property string iconThemeStatus:  "file:///usr/share/icons/breeze/status/22/"
    readonly property string iconThemeDevices: "file:///usr/share/icons/breeze/devices/22/"
    readonly property string iconWifi:       iconThemeDevices + "network-wireless-symbolic.svg"
    readonly property string iconBluetooth:  iconThemeStatus  + "network-bluetooth-symbolic.svg"
    readonly property string iconSettings:   iconThemeActions  + "configure-symbolic.svg"
    readonly property string iconNotif:      iconThemeActions  + "notifications-symbolic.svg"
    readonly property string iconRefresh:    iconThemeActions  + "view-refresh-symbolic.svg"
    readonly property string iconBrightness: iconThemeActions  + "brightness-high-symbolic.svg"
    readonly property string iconAudio:      iconThemeStatus  + "audio-volume-high-symbolic.svg"
    readonly property string iconKbd:        iconThemeDevices + "input-keyboard-symbolic.svg"
    readonly property string iconScreenshot: iconThemeActions  + "view-fullscreen-symbolic.svg"
    readonly property string iconRecord:     iconThemeActions  + "media-record-symbolic.svg"
    readonly property string iconThemeApp:   iconThemeActions  + "games-config-theme-symbolic.svg"

    // TYPOGRAPHY --- family names only, sizes now live in Tokens
    readonly property string fontMono:    "Fira Code"
    readonly property string fontDisplay: "KogniGear"

    // OPACITY --- unitless, correctly does NOT scale with screen size
    readonly property real opacityBar:    0.8
    readonly property real opacityPanel:  0.96
    readonly property real opacityMuted:  0.45
    readonly property real opacityVisible: 1.0
    readonly property real opacityHidden:  0.0
    readonly property real opacityConsole: 0.95

    // ---
    //  ANIMATION EASING NOTES
    // ---
    //  Straighten phase: Easing.InOutCubic  --- mechanical, deliberate
    //  Expand phase:     Easing.OutCubic    --- decisive deployment
    //  Fade phase:       Easing.InQuad      --- content materializes
}
