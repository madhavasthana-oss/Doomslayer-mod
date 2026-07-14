pragma Singleton
import QtQuick 2.15
import "."

QtObject {

    // =========================================================
    //  DOOMSHELL — TOKENS SINGLETON
    //  Single source of truth for every scaled size/spacing value.
    //  Globals owns screen detection + scaleFactor + app state.
    //  Theme owns colors + font family names + opacity.
    //  Everything else that is a PIXEL VALUE lives here.
    // =========================================================

    readonly property real scale: Globals.scaleFactor

    // SPACING SCALE
    readonly property int spacingUnit: Math.round(4  * scale)
    readonly property int spacingXs:   Math.round(4  * scale)
    readonly property int spacingSm:   Math.round(6  * scale)
    readonly property int spacingMd:   Math.round(10 * scale)
    readonly property int spacingLg:   Math.round(16 * scale)
    readonly property int spacingXl:   Math.round(24 * scale)

    readonly property int inMostSpacing: Math.round(5 * scale)
    readonly property int columnSpacing: Math.round(4 * scale)
    readonly property int marginTop:     0

    readonly property int paddingH: Math.round(6 * scale)
    readonly property int paddingV: Math.round(6 * scale)

    readonly property int barGap:       Math.round(0 * scale)
    readonly property int barMarginTop: Math.round(8 * scale)

    // RADII
    readonly property int radiusSm: Math.round(3  * scale)
    readonly property int radiusMd: Math.round(5  * scale)
    readonly property int radiusLg: Math.round(6  * scale)
    readonly property int radiusXl: Math.round(10 * scale)

    // BAR GEOMETRY
    // NOTE: Theme had barHeightSide=20 / barHeightCenter=30 (stale, unused).
    // Globals had leftHeight=rightHeight=35 / centerHeight=45 (actually driving
    // shell.qml). Kept Globals numbers as canonical — verify before deleting
    // the old Theme copies.
    readonly property int leftWidth:    Math.round(350 * scale)
    readonly property int leftHeight:   Math.round(35  * scale)
    readonly property int rightWidth:   Math.round(350 * scale)
    readonly property int rightHeight:  Math.round(35  * scale)
    readonly property int centerWidth:  Math.round(640 * scale)
    readonly property int centerHeight: Math.round(45  * scale)

    readonly property int centerSmallerWidth: centerWidth - 2 * (centerHeight + inMostSpacing)

    readonly property int preferredWidthNoGreeting: Math.round(80  * scale)
    readonly property int greetingWidth:            Math.round(204 * scale)

    readonly property int exclusiveZone: Math.round(45 * scale)

    // CENTER EXPANSION GEOMETRY
    readonly property int centerCollapsedWidth:  Math.round(640 * scale)
    readonly property int centerCollapsedHeight: Math.round(30  * scale)
    readonly property int centerExpandedWidth:   Math.round(580 * scale)
    readonly property int centerExpandedHeight:  Math.round(220 * scale)

    readonly property int angleOffsetCollapsed: Math.round(30 * scale)
    readonly property int angleOffsetExpanded:  0
    readonly property int angleOffsetDefault:   Math.round(45 * scale)

    // PANEL DIMENSIONS
    readonly property int statPanelWidth:  Math.round(580 * scale)
    readonly property int statPanelHeight: Math.round(190 * scale)

    // DROPDOWN / LIST GEOMETRY
    readonly property int listPanelWidth:   Math.round(108 * scale)
    readonly property int listRowHeight:    Math.round(22  * scale)
    readonly property int statBoxHeight:    Math.round(40  * scale)
    readonly property int actionBtnHeight:  Math.round(28  * scale)
    readonly property int tabHeight:        Math.round(20  * scale)
    readonly property int sliderTrackWidth: Math.round(50  * scale)
    readonly property int sliderTrackDepth: Math.round(4   * scale)
    readonly property int usageBarHeight:   Math.round(4   * scale)

    // EDGE PANELS
    readonly property int edgeHoverZoneWidth: Math.round(40  * scale)
    readonly property int edgePanelWidth:     Math.round(280 * scale)
    readonly property int edgeToggleHeight:   Math.round(48  * scale)
    readonly property int edgeHotzonePx:      Math.round(4   * scale)

    // ICONS
    // NOTE — UNRESOLVED CONFLICT, confirm manually:
    // Globals had iconSizeSmall/Base/Medium/Large = 4/8/12/14 (scaled)
    // Theme   had iconSizeSmall/Base/Large        = 4/8/10    (unscaled, no Medium)
    // Kept Globals' 4-tier version below. Grep both `Theme.iconSize` and
    // `Globals.iconSize` across your repo before deleting either source —
    // whichever is actually driving your visible icons today is the one
    // whose numbers you want here.
    readonly property int iconSizeSmall:  Math.round(4  * scale)
    readonly property int iconSizeBase:   Math.round(8  * scale)
    readonly property int iconSizeMedium: Math.round(12 * scale)
    readonly property int iconSizeLarge:  Math.round(14 * scale)

    // TYPOGRAPHY (sizes only — Theme keeps font family + colors)
    readonly property int fontSizeTiny:    Math.round(9  * scale)
    readonly property int fontSizeSmall:   Math.round(11 * scale)
    readonly property int fontSizeBase:    Math.round(13 * scale)
    readonly property int fontSizeLabel:   Math.round(9  * scale)
    readonly property int fontSizeConsole: Math.round(11 * scale)
    readonly property int fontSizeMedium:  Math.round(16 * scale)
    readonly property int fontSizeStat:    Math.round(18 * scale)
    readonly property int fontSizeLarge:   Math.round(22 * scale)
    readonly property int fontSizeHuge:    Math.round(32 * scale)

    readonly property real monoCharWidth:  fontSizeSmall  * 0.6
    readonly property real kogniCharWidth: fontSizeBase   * 0.75
    readonly property real kogniMedWidth:  fontSizeMedium * 0.75

    // STROKE / BORDER (moved from Theme — a stroke width is a size, not an identity)
    readonly property real strokeWidth:       1.0 * scale
    readonly property real strokeWidthActive: 1.5 * scale

    // BLUR
    readonly property int blurRadius: Math.round(18 * scale)

    // BAR VISUAL GEOMETRY (moved from Globals — spacing/inset, not state)
    readonly property int barInset: Math.round(6 * scale)

    // WORKSPACE
    readonly property int workspaceToggleMargin: Math.round(10 * scale)
    readonly property int workspaceMargins:      Math.round(6  * scale)

    // ANIMATION TIMINGS — deliberately NOT scaled, duration is perceptual not spatial
    readonly property int animFast:       120
    readonly property int animMedium:     220
    readonly property int animSlow:       400
    readonly property int animStraighten: 150
    readonly property int animExpand:     300
    readonly property int animFadeIn:     150
    readonly property int animFadeDelay:  450
}