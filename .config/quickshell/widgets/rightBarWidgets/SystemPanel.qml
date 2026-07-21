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
    implicitHeight: mainTelemetryLayout.implicitHeight
    implicitWidth: mainTelemetryLayout.implicitWidth
    ColumnLayout{
        id: mainTelemetryLayout
        // 1. Shared tab bar (lives above everything)
        SystemTabs {
            id: tabs
            Layout.leftMargin: Tokens.paddingH
            Layout.rightMargin: Tokens.paddingH

            active: Globals.activePanel
            onSwitched: (panel) => { Globals.activePanel = panel }   // <- this line
        }

        // 2. Separator line
        Rectangle {
            id: sep
            Layout.leftMargin: Tokens.paddingH
            Layout.rightMargin: Tokens.paddingH
            Layout.preferredHeight: Tokens.strokeWidth
            Layout.fillWidth: true
            color: Theme.borderIdle
            opacity: 0.5
        }

        // 3. The three content panels (pure content now)
        StackLayout {
            id: stack

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
