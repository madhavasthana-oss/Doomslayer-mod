pragma Singleton
import QtQuick 2.15

QtObject {

    // Backgrounds
    readonly property color bgPrimary:   "#0D0000"
    readonly property color bgSurface:   "#1A0000"
    readonly property color bgElevated:  "#2A0500"

    // Core accents
    readonly property color accent:      "#FF4500"
    readonly property color accentWarm:  "#FFCA80"
    readonly property color accentSoft:  "#FF80BF"

    // Text
    readonly property color textPrimary:   "#FF4500"
    readonly property color textSecondary: "#FFCA80"
    readonly property color textMuted:     "#CC2200"
    readonly property color textDim:       "#601000"

    // State colors
    readonly property color stateCritical: "#CC2200"
    readonly property color stateSafe:     "#8AFF80"
    readonly property color stateWarning:  "#FFCA80"

    // Border / stroke color (widths now live in Tokens)
    readonly property color borderActive:  "#FF4500"
    readonly property color borderIdle:    "#CC2200"

    // Expansion panel visuals
    readonly property color bgConsole:     "#1F0200"
    readonly property color borderConsole: "#CC2200"
    readonly property color glowConsole:   "#994400"

    // TYPOGRAPHY — family names only, sizes now live in Tokens
    readonly property string fontMono:    "JetBrains Mono"
    readonly property string fontDisplay: "KogniGear"

    // OPACITY — unitless, correctly does NOT scale with screen size
    readonly property real barOpacity:    0.8
    readonly property real opacityBar:    0.92
    readonly property real opacityPanel:  0.96
    readonly property real opacityMuted:  0.45
    readonly property real opacityVisible: 1.0
    readonly property real opacityHidden:  0.0
    readonly property real opacityConsole: 0.95

    // ---------------------------------------------------------
    //  ANIMATION EASING NOTES
    // ---------------------------------------------------------
    //  Straighten phase: Easing.InOutCubic  — mechanical, deliberate
    //  Expand phase:     Easing.OutCubic    — decisive deployment
    //  Fade phase:       Easing.InQuad      — content materializes
}