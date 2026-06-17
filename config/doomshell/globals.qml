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
    // helper Fonts
    // ---------------------------------------------------------
    readonly property int fontSizeSmall:  11
    readonly property int fontSizeBase:   13
    readonly property int fontSizeMedium: 16

    // ---------------------------------------------------------
    //  CENTER BAR
    // ---------------------------------------------------------

    readonly property int centerWidth:          640
    // inMostSpacing is 5, 
    readonly property int centerSmallerWidth:   centerWidth - 2 * (centerHeight + inMostSpacing) 
    readonly property int centerHeight:         45

    // Character width estimates
    // JetBrains Mono is monospace — very predictable at ~0.6× ratio
    // KogniGear is display — runs wide at ~0.75× ratio
    readonly property real monoCharWidth:    fontSizeSmall  * 0.6   // ~6.6px per char
    readonly property real kogniCharWidth:   fontSizeBase   * 0.75  // ~9.75px per char
    readonly property real kogniMedWidth:    fontSizeMedium * 0.75  // ~12px per char

    // these values are now derived with logic, will update automatically
    /*
        the key idea is that the center bar is of length centerSmallerWidth effectively

        ---------------------------------------------------------------
         \                                                           /
          \_________________________________________________________/
         the bottom length is of length centerSmallerWidth

         the problem now rises that there are 4 margins, say they are of value x
         max(space_bottom_text) = monoCharWidth * 12 ---> the ram entry = bottom_space

         that means 4 * (bottom_space + margin) + kogniMedWidth * 17 <= centerSmallerWidth

         that is the satisfying constraint

         ------------------------------------------------------------------------

         holding the fonts as variable, and likewise only modulating them, we get

         for bottom space = 6.6 * 12 = 79.2 --> 80
         
         and kogniMedWidth * 17 = 17 * 12 = 204

         we get 4 * (80 + margin) + 204 = 540 for the current values

         that gives margin = 336 / 4 - 80 = 4 

    */ 
    readonly property int preferredWidthNoGreeting: 80
    readonly property int columnSpacing:        4
    readonly property int columnCount:          5
    readonly property int rowCount:             2
    readonly property int greetingWidth:        204

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