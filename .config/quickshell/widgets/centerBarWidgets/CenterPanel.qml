// CenterPanel.qml
import QtQuick
import QtQuick.Layouts
import "../.."
import "."

Item {
    id: root
    implicitHeight: mainCenterPanelLayout.implicitHeight
    implicitWidth:  mainCenterPanelLayout.implicitWidth

    ColumnLayout {
        id: mainCenterPanelLayout

        CenterTabs {
            id: tabs
            Layout.leftMargin:  Tokens.paddingH
            Layout.rightMargin: Tokens.paddingH

            active: Globals.activeCenterPanel
            onSwitched: (panel) => { Globals.activeCenterPanel = panel }
        }

        // 2. Separator line
        Rectangle {
            id: sep
            Layout.leftMargin:  Tokens.paddingH
            Layout.rightMargin: Tokens.paddingH
            Layout.preferredHeight: 1
            Layout.fillWidth: true
            color: Theme.borderIdle
            opacity: 0.5
        }

        // 3. Content panels (placeholders for now)
        StackLayout {
            id: stack

            currentIndex: {
                let panels = ["dashboard","console","media"]
                return panels.indexOf(Globals.activeCenterPanel)
            }

            DashboardWidget { id: dashboard }
            ConsoleWidget   { id: consoleView }
            MediaWidget     { id: media }
        }
    }
}
