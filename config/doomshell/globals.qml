pragma Singleton
import QtQuick 2.15

QtObject {

    // =========================================================
    //  DOOMSHELL — GLOBALS SINGLETON
    //  Runtime layout constants — bar dimensions, positions.
    //  These are the decided values from shell.qml testing.
    //
    //  Usage in any .qml file:
    //    import "../globals.qml" as Globals
    //    width: Globals.centerWidth
    // =========================================================

    readonly property double barOpacity: 0.8
    readonly property int barInset: 6

    // ---------------------------------------------------------
    //  LEFT BAR
    // ---------------------------------------------------------

    readonly property int leftWidth:  350
    readonly property int leftHeight: 35


    // ---------------------------------------------------------
    //  CENTER BAR
    // ---------------------------------------------------------

    readonly property int centerWidth:          640
    readonly property int centerHeight:         45
    readonly property int columnSpacing:        50
    readonly property int columnCount:          5
    readonly property int rowCount:             2
    readonly property int greetingWidth:        120

    // derived — update automatically
    readonly property int totalSpacing:         columnSpacing * (columnCount - 1)
    readonly property int availableWidth:       centerWidth - (inMostSpacing * 2) - totalSpacing
    readonly property int preferredColumnWidth: Math.floor((availableWidth - greetingWidth) / (columnCount - 1))


    // ---------------------------------------------------------
    //  RIGHT BAR
    // ---------------------------------------------------------

    readonly property int rightWidth:  350
    readonly property int rightHeight: 35


    // ---------------------------------------------------------
    //  SHARED
    // ---------------------------------------------------------

    readonly property int exclusiveZone: 45     // bars float, don't push windows
    readonly property int marginTop:     0      // flush to screen top
    readonly property int inMostSpacing: 5
    // ---------------------------------------------------------
    //  ANIMATION STATE
    // ---------------------------------------------------------

    // Active panel tracker — single source of truth
    // Values: "" | "cpu" | "gpu" | "ram" | "bat" | "greeting"
    property string activePanel: ""

    // Derived expansion state
    readonly property bool expanded: activePanel !== ""


    // ---------------------------------------------------------
    //  CENTER BAR EXPANSION GEOMETRY
    // ---------------------------------------------------------

    // Collapsed state — current bar dimensions
    readonly property int centerCollapsedWidth:  640
    readonly property int centerCollapsedHeight: 30

    // Expanded state — telemetry console dimensions
    // Width inherits from SHORT edge (bottom of trapezoid)
    // short edge = centerCollapsedWidth - 2 * angleOffset
    // angleOffset = barHeight = 30
    // short edge = 640 - 60 = 580
    readonly property int centerExpandedWidth:  580    // short edge footprint
    readonly property int centerExpandedHeight: 220    // console deploy height

    // Angle offset — drives trapezoid morph
    // collapsed: angleOffset = barHeight (full 45°)
    // expanded:  angleOffset = 0 (rectangle)
    readonly property int angleOffsetCollapsed: 30     // == centerCollapsedHeight
    readonly property int angleOffsetExpanded:  0


    // ---------------------------------------------------------
    //  PANEL CONTENT DIMENSIONS
    //  Each stat panel fits within the expanded console
    // ---------------------------------------------------------

    readonly property int statPanelWidth:  580
    readonly property int statPanelHeight: 190    // expanded height minus header row


    // ---------------------------------------------------------
    //  ANIMATION TIMING — sequential deployment
    // ---------------------------------------------------------

    readonly property int animStraighten:  150   // 0–150ms:   trapezoid → rectangle
    readonly property int animExpand:      300   // 150–450ms: height expansion
    readonly property int animFadeIn:      150   // 450–600ms: content appears
    readonly property int animFadeDelay:   450   // content fade starts after expand

    // ---------------------------------------------------------
    // TEXT FADE IN - Animation
    // ---------------------------------------------------------

    readonly property int greetingAnim:   500   // content fade starts after expand
    readonly property int gpuAndRamAnim:   1000   // content fade starts after expand
    readonly property int cpuAndTempAnim:   1500   // content fade starts after expand
    readonly property int activeWindowAndBatteryAndVolumeAnim:   2000   // content fade starts after expand

    // ---------------------------------------------------------
    //  WORKSPACE HELPERS — Margins and number of workspaces
    // ---------------------------------------------------------
    readonly property int workspaceToggleMargin: 10
    readonly property int workspaceMargins: 6
    readonly property int workspaceNumber : 7

    // ---------------------------------------------------------
    // Icon helpers
    // ---------------------------------------------------------

    readonly property int iconSizeSmall: 4
    readonly property int iconSizeBase: 8
    readonly property int iconSizeMedium: 10
    readonly property int iconSizeLarge: 16
}   