pragma Singleton
import QtQuick 2.15
import Quickshell

QtObject {

    // =========================================================
    //  SCREEN-AWARE SCALING (NEW)
    // =========================================================
    readonly property var primaryScreen: Quickshell.screens.length > 0 ? Quickshell.screens[0] : null
    
    // Scale based on screen width (1920px as baseline). Adjust min/max as needed.
    readonly property real scaleFactor: primaryScreen ? 
        Math.max(1, Math.min(1.45, primaryScreen.width / 1920)) : 1.0

    // Optional: You can also factor in DPI if you want
    readonly property real dpiScale: primaryScreen ? primaryScreen.devicePixelRatio : 1.0

    // =========================================================
    //  DOOMSHELL — GLOBALS SINGLETON
    // =========================================================

    readonly property double barOpacity: 0.8
    readonly property int barInset: 6

    // LEFT / RIGHT BAR
    readonly property int leftWidth:   Math.round(350 * scaleFactor)
    readonly property int leftHeight:  Math.round(35 * scaleFactor)
    readonly property int rightWidth:  Math.round(350 * scaleFactor)
    readonly property int rightHeight: Math.round(35 * scaleFactor)

    // Fonts (scaled)
    readonly property int fontSizeSmall:  Math.round(11 * scaleFactor)
    readonly property int fontSizeBase:   Math.round(13 * scaleFactor)
    readonly property int fontSizeMedium: Math.round(16 * scaleFactor)

    // CENTER BAR
    readonly property int centerWidth:  Math.round(640 * scaleFactor)
    readonly property int centerHeight: Math.round(45 * scaleFactor)
    
    readonly property int centerSmallerWidth: centerWidth - 2 * (centerHeight + inMostSpacing)

    // Character width estimates (auto-scale with fonts)
    readonly property real monoCharWidth:  fontSizeSmall  * 0.6
    readonly property real kogniCharWidth: fontSizeBase   * 0.75
    readonly property real kogniMedWidth:  fontSizeMedium * 0.75

    readonly property int preferredWidthNoGreeting: Math.round(80 * scaleFactor)
    readonly property int columnSpacing:        Math.round(4 * scaleFactor)
    readonly property int greetingWidth:        Math.round(204 * scaleFactor)

    // SHARED
    readonly property int exclusiveZone: Math.round(45 * scaleFactor)
    readonly property int marginTop:     0
    readonly property int inMostSpacing: Math.round(5 * scaleFactor)

    // CENTER EXPANSION GEOMETRY
    readonly property int centerCollapsedWidth:  Math.round(640 * scaleFactor)
    readonly property int centerCollapsedHeight: Math.round(30 * scaleFactor)
    readonly property int centerExpandedWidth:   Math.round(580 * scaleFactor)
    readonly property int centerExpandedHeight:  Math.round(220 * scaleFactor)

    readonly property int angleOffsetCollapsed: Math.round(30 * scaleFactor)
    readonly property int angleOffsetExpanded:  0

    // PANEL DIMENSIONS
    readonly property int statPanelWidth:  Math.round(580 * scaleFactor)
    readonly property int statPanelHeight: Math.round(190 * scaleFactor)

    // ICONS
    readonly property int iconSizeSmall:  Math.round(4 * scaleFactor)
    readonly property int iconSizeBase:   Math.round(8 * scaleFactor)
    readonly property int iconSizeMedium: Math.round(12 * scaleFactor)
    readonly property int iconSizeLarge:  Math.round(14 * scaleFactor)

    // Animation timings (no need to scale these usually)
    readonly property int animStraighten:  150
    readonly property int animExpand:      300
    readonly property int animFadeIn:      150
    readonly property int animFadeDelay:   450

    // Workspace / other
    readonly property int workspaceToggleMargin: Math.round(10 * scaleFactor)
    readonly property int workspaceMargins:      Math.round(6 * scaleFactor)
    readonly property int workspaceNumber : 7

//    █████████                       █████                       ████         
//   ███▒▒▒▒▒███                     ▒▒███                       ▒▒███         
//  ███     ▒▒▒   ██████  ████████   ███████   ████████   ██████  ▒███   █████ 
// ▒███          ███▒▒███▒▒███▒▒███ ▒▒▒███▒   ▒▒███▒▒███ ███▒▒███ ▒███  ███▒▒  
// ▒███         ▒███ ▒███ ▒███ ▒███   ▒███     ▒███ ▒▒▒ ▒███ ▒███ ▒███ ▒▒█████ 
// ▒▒███     ███▒███ ▒███ ▒███ ▒███   ▒███ ███ ▒███     ▒███ ▒███ ▒███  ▒▒▒▒███
//  ▒▒█████████ ▒▒██████  ████ █████  ▒▒█████  █████    ▒▒██████  █████ ██████ 
//   ▒▒▒▒▒▒▒▒▒   ▒▒▒▒▒▒  ▒▒▒▒ ▒▒▒▒▒    ▒▒▒▒▒  ▒▒▒▒▒      ▒▒▒▒▒▒  ▒▒▒▒▒ ▒▒▒▒▒▒  
                                                                            
                                                                            
                                                                            
    // Active panel tracker — single source of truth
    // Values: "" | "cpu" | "gpu" | "ram" | "bat" | "greeting"
    property string activePanel    : ""
    property string lastPanel      : "cpu" 
    property bool consolePanelOpen : false
}   