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
        "bat": 0,
        "aud": 1,
        "cpu": 2,
        "gpu": 3,
        "ram": 4
    })

    StackLayout {
        id: stack
        anchors.fill: parent

        // Drive the index from your existing Globals.activePanel
        currentIndex: rightWidget.panelIndex[Globals.activePanel] ?? 2

        // Index 0 — BAT (placeholder for now)
        Item { }

        // Index 1 — AUD (placeholder for now)
        Item { }

        // Index 2 — CPU
        CPUFrontend { }

        // Index 3 — GPU
        GPUFrontend { }

        // Index 4 — RAM (placeholder for now)
        Item { }
    }
}