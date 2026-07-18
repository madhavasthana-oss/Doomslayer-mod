pragma Singleton
import Quickshell
import QtQuick 2.15
import "."

QtObject {

    // ---- PRIMARY SCREEN ----
    readonly property var primaryScreen: Qt.application.screens.length > 0 ? 
                                        Qt.application.screens[0] : null

    // ---- DPI SCALE ----
    readonly property real dpiScale: primaryScreen ? 
                                         primaryScreen.devicePixelRatio : 1.0

    property real customScale: 1

    // ---- AUTO-COMPUTED SCALE ----
    readonly property real resScale: primaryScreen ?
        Math.min(primaryScreen.width / 1920, primaryScreen.height / 1080) : 1.0

    readonly property real predefinedScale: primaryScreen ?
        Math.max(0.65, Math.min(1.0, resScale * dpiScale)) : 1.0

    readonly property real scale: customScale > 0 ? customScale : predefinedScale
    // SPACING SCALE

    readonly property int spacingXss: Math.round(2 * scale)
    readonly property int spacingXs:  Math.round(4  * scale)
    readonly property int spacingSm:  Math.round(6  * scale)
    readonly property int spacingMd:  Math.round(10 * scale)
    readonly property int spacingLg:  Math.round(16 * scale)
    readonly property int spacingXl:  Math.round(24 * scale)

    readonly property int borderXss: Math.round(2 * scale)
    readonly property int borderXs:  Math.round(4 * scale)
    readonly property int borderSm:  Math.round(6 * scale)
    readonly property int borderMd:  Math.round(10 * scale)
    readonly property int borderLg:  Math.round(16 * scale)
    
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

    readonly property int centerSmallerWidth: centerWidth - 2 * (centerHeight + spacingXs)

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
    readonly property int usageBarWidth:    Math.round(50  * scale)
    readonly property int usageBarHeight:   Math.round(4   * scale)

    // EDGE PANELS
    readonly property int edgeHoverZoneWidth: Math.round(40  * scale)
    readonly property int edgePanelWidth:     Math.round(280 * scale)
    readonly property int edgeToggleHeight:   Math.round(48  * scale)
    readonly property int edgeHotzonePx:      Math.round(4   * scale)

    readonly property int iconSizeSmall:  Math.round(4  * scale)
    readonly property int iconSizeBase:   Math.round(8  * scale)
    readonly property int iconSizeMedium: Math.round(12 * scale)
    readonly property int iconSizeLarge:  Math.round(14 * scale)


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

    readonly property real strokeWidth:       1.0 * scale
    readonly property real strokeWidthActive: 1.5 * scale

    readonly property int blurRadius: Math.round(18 * scale)

    readonly property int barInset: Math.round(6 * scale)

    readonly property int workspaceToggleMargin: Math.round(10 * scale)
    readonly property int workspaceMargins:      Math.round(6  * scale)

    readonly property int animFast:       120
    readonly property int animMedium:     220
    readonly property int animSlow:       400
    readonly property int animStraighten: 150
    readonly property int animExpand:     300
    readonly property int animFadeIn:     150
    readonly property int animFadeDelay:  450
}
