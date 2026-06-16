pragma Singleton
import QtQuick 2.15

QtObject {

    // =========================================================
    //  DOOMSHELL — THEME SINGLETON
    //  Adventure palette, extracted from doomslayer-3.omp.json
    //  and fastfetch config.
    //
    //  Usage in any .qml file:
    //    import "../theme.qml" as Theme  (adjust path as needed)
    //    color: Theme.accent
    // =========================================================


    // ---------------------------------------------------------
    //  COLOR PALETTE
    // ---------------------------------------------------------
    // Backgrounds
    readonly property color bgPrimary:   "#0D0000"   // near-black, red undertone — wallpaper/void
    readonly property color bgSurface:   "#1A0000"   // bar fill — slightly lifted from void
    readonly property color bgElevated:  "#2A0500"   // hover states, panel surfaces

    // Core accents
    readonly property color accent:      "#FF4500"   // OMP leading diamonds, borders — the fire
    readonly property color accentWarm:  "#FFCA80"   // RAM, execution time, highlights — ember
    readonly property color accentSoft:  "#FF80BF"   // kubectl, project — faint rose

    // ---------------------------------------------------------
    //  TEXT — replace these lines in theme.qml
    // ---------------------------------------------------------

    readonly property color textPrimary: "#FF4500"   // fire red — dominant text
    readonly property color textSecondary: "#FFCA80" // ember — secondary labels
    readonly property color textMuted:   "#CC2200"   // deep red — de-emphasized
    readonly property color textDim:     "#3D0A00"   // barely visible — decorative

    // State colors
    readonly property color stateCritical: "#CC2200" // errors, critical thermals — deep red
    readonly property color stateSafe:     "#8AFF80" // success, safe temps, charging — acid green
    readonly property color stateWarning:  "#FFCA80" // warm warning — reuses accentWarm

    // Border / stroke
    readonly property color borderActive:  "#FF4500" // active bar borders
    readonly property color borderIdle:    "#3D0A00" // idle/dim borders


    // ---------------------------------------------------------
    //  TYPOGRAPHY
    // ---------------------------------------------------------

    readonly property string fontMono:    "JetBrains Mono"
    readonly property string fontDisplay: "KogniGear"

    // Font sizes
    readonly property int fontSizeTiny:   9
    readonly property int fontSizeSmall:  11
    readonly property int fontSizeBase:   13
    readonly property int fontSizeMedium: 16
    readonly property int fontSizeLarge:  22
    readonly property int fontSizeHuge:   32


    // ---------------------------------------------------------
    //  BAR GEOMETRY
    // ---------------------------------------------------------

    readonly property int barHeightSide:   20
    readonly property int barHeightCenter: 30

    readonly property int barWidthSide:    350
    readonly property int barWidthCenter:  640

    // Trapezoid angle offset in pixels
    // 45px over 30px height ≈ 45° — clean, intentional, not aggressive
    readonly property int angleOffset:     45

    // Gap between bars — the seam / visor crack
    readonly property int barGap:          0

    readonly property int barMarginTop:    8

    readonly property int paddingH:        12
    readonly property int paddingV:        6


    // ---------------------------------------------------------
    //  STROKE / BORDER
    // ---------------------------------------------------------

    readonly property real strokeWidth:       1.0
    readonly property real strokeWidthActive: 1.5


    // ---------------------------------------------------------
    //  ANIMATION
    // ---------------------------------------------------------

    readonly property int animFast:   120
    readonly property int animMedium: 220
    readonly property int animSlow:   400


    // ---------------------------------------------------------
    //  EDGE PANELS
    // ---------------------------------------------------------

    readonly property int edgePanelWidth: 280
    readonly property int edgeHotzonePx:  4


    // ---------------------------------------------------------
    //  OPACITY
    // ---------------------------------------------------------

    readonly property real opacityBar:   0.92
    readonly property real opacityPanel: 0.96
    readonly property real opacityMuted: 0.45


    // ---------------------------------------------------------
    //  BLUR
    // ---------------------------------------------------------

    readonly property int blurRadius: 18


    // ---------------------------------------------------------
    //  ICON SIZES
    // ---------------------------------------------------------

    readonly property int iconSizeSmall: 14
    readonly property int iconSizeBase:  18
    readonly property int iconSizeLarge: 24

}
