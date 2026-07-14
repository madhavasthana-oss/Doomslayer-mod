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
        // 1. Shared tab bar (lives above everything)
        SystemTabs {
            id: tabs
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: Tokens.paddingH
            anchors.rightMargin: Tokens.paddingH
            anchors.topMargin: Tokens.paddingH

            active: Globals.activePanel
            onSwitched: (panel) => { Globals.activePanel = panel }   // ← this line
        }

        // 2. Separator line
        Rectangle {
            id: sep
            anchors.top: tabs.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.topMargin: Tokens.inMostSpacing
            anchors.leftMargin: Tokens.paddingH
            anchors.rightMargin: Tokens.paddingH
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
            anchors.topMargin: Tokens.inMostSpacing * 2
            anchors.leftMargin: Tokens.paddingH
            anchors.rightMargin: Tokens.paddingH
            anchors.bottomMargin: Tokens.paddingH

            currentIndex: {
                let panels = ["cpu", "gpu", "ram"]
                return panels.indexOf(Tokens.activePanel)
            }

            CPUFrontend  { id: cpu }
            GPUFrontend  { id: gpu }
            RAMFrontend  { id: ram }
        }
    }
}