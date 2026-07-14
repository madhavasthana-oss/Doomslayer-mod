// SystemPanel.qml
import QtQuick
import QtQuick.Layouts
import "../.."
import "system/CPU"
import "system/GPU"
import "system/RAM"
import "."

Item {
    id: root
    ColumnLayout{
        id: mainTelemetryLayout
        spacing: Globals.inMostSpacing
        // 1. Shared tab bar (lives above everything)
        SystemTabs {
            id: tabs
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: Theme.paddingH
            anchors.rightMargin: Theme.paddingH
            anchors.topMargin: Theme.paddingH

            active: Globals.activePanel
            onSwitched: (panel) => { Globals.activePanel = panel }   // ← this line
        }

        // 2. Separator line
        Rectangle {
            id: sep
            anchors.top: tabs.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.topMargin: Globals.inMostSpacing
            anchors.leftMargin: Theme.paddingH
            anchors.rightMargin: Theme.paddingH
            height: 1
            color: Theme.borderIdle
            opacity: 0.5
        }

        // 3. The three content panels (pure content now)
        StackLayout {
            id: stack
            anchors.top: sep.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.topMargin: Globals.inMostSpacing * 2
            anchors.leftMargin: Theme.paddingH
            anchors.rightMargin: Theme.paddingH
            anchors.bottomMargin: Theme.paddingH

            currentIndex: {
                let panels = ["cpu", "gpu", "ram"]
                return panels.indexOf(Globals.activePanel)
            }

            CPUFrontend  { id: cpu }
            GPUFrontend  { id: gpu }
            RAMFrontend  { id: ram }
        }
    }
}