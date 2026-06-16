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


    // ---------------------------------------------------------
    //  LEFT BAR
    // ---------------------------------------------------------

    readonly property int leftWidth:  340
    readonly property int leftHeight: 25


    // ---------------------------------------------------------
    //  CENTER BAR
    // ---------------------------------------------------------

    readonly property int centerWidth:  640
    readonly property int centerHeight: 35


    // ---------------------------------------------------------
    //  RIGHT BAR
    // ---------------------------------------------------------

    readonly property int rightWidth:  340
    readonly property int rightHeight: 25


    // ---------------------------------------------------------
    //  SHARED
    // ---------------------------------------------------------

    readonly property int exclusiveZone: 0      // bars float, don't push windows
    readonly property int marginTop:     0      // flush to screen top

}