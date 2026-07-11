import QtQuick
import QtQuick.Layouts
import Quickshell
import "../.."

Item {
    id: rightWidget

    width:  Globals.rightWidth
    height: Globals.rightWidth * 8 / 7

    // Map panel name → stack index
    readonly property var panelIndex: ({
        "cpu": 0,
        "gpu": 1,
        "ram": 2
    })

    StackLayout {
        id: stack
        anchors.fill: parent

        // Drive the index from your existing Globals.activePanel
        currentIndex: rightWidget.panelIndex[Globals.activePanel] ?? 2

        // Index 0 — CPU
        CPUFrontend { }

        // Index 1 — GPU
        GPUFrontend { }

        // Index 2 — RAM (placeholder for now)
        Item { }
    }
}
