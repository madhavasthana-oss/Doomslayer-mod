import QtQuick
import Quickshell
import Quickshell.Wayland
import QtQuick.Layouts
import "utils"
import "bars"
import "."
import "widgets/rightBarWidgets/system/CPU"
import "widgets/rightBarWidgets/system/GPU"
import "widgets/rightBarWidgets/system/RAM"

ShellRoot {

    PanelWindow {
        id: rightBarWindow
        anchors { top: true; right: true }
        implicitWidth:  Globals.rightWidth
        implicitHeight: Globals.rightHeight 
        color: "transparent"
        exclusiveZone: Globals.exclusiveZone
        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.namespace: "doomshell-right"

        RightBar { anchors.fill: parent }
    }
    

    PanelWindow {
        id: dropdownWindow
        anchors { top: true; right: true }
        implicitWidth:  350
        implicitHeight: Globals.activePanel !== "" ? 400 : 0

        Behavior on implicitHeight {
            NumberAnimation { duration: 50; easing.type: Easing.OutQuart }
        }

        color:         "transparent"
        exclusiveZone: 0
        WlrLayershell.layer:         WlrLayer.Top
        WlrLayershell.namespace:     "doomshell-dropdown"
        WlrLayershell.margins.top:   0
        WlrLayershell.margins.right: 5
        visible: Globals.activePanel !== ""

        StackLayout {
            anchors.fill: parent

                currentIndex: {
                    let panels = ["cpu", "gpu", "ram"]
                    return panels.indexOf(Globals.activePanel)
                }

                CPUFrontend { id: cpu }      // 2 — CPU
                GPUFrontend { id: gpu }      // 3 — GPU
                RAMFrontend { id: ram }      // 4 — RAM placeholder
            }
        }
        

    PanelWindow {
        id: leftBarWindow
        anchors { top: true; left: true }
        implicitWidth:  Globals.leftWidth
        implicitHeight: Globals.leftHeight
        color: "transparent"
        exclusiveZone: Globals.exclusiveZone
        WlrLayershell.layer:     WlrLayer.Top
        WlrLayershell.namespace: "doomshell-left"

        LeftBar { anchors.fill: parent }
    }

    PanelWindow {
        id: centerBarWindow
        anchors { top: true }
        implicitWidth:  Globals.centerWidth
        implicitHeight: Globals.centerHeight
        color: "transparent"
        exclusiveZone: Globals.exclusiveZone
        WlrLayershell.layer:     WlrLayer.Top
        WlrLayershell.namespace: "doomshell-center"

        CenterBar { anchors.fill: parent }
    }
}
