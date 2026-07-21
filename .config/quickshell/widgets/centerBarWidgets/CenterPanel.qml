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
            onSwitched: (panel) => {
                Globals.activeCenterPanel = panel
                Globals.lastCenterPanel = panel
            }
        }

        // 2. Separator line
        Rectangle {
            id: sep
            Layout.leftMargin:  Tokens.paddingH
            Layout.rightMargin: Tokens.paddingH
            Layout.preferredHeight: Tokens.strokeWidth
            Layout.fillWidth: true
            color: Theme.borderIdle
            opacity: 0.5
        }

        // 3. Content panels — fixed token footprint so token height toggles
        // stay consistent across tabs (no implicit-size thrash in StackLayout)
        StackLayout {
            id: stack
            Layout.preferredWidth:  Tokens.centerSmallerWidth
            Layout.preferredHeight: Tokens.centerExpandedHeight
            Layout.minimumHeight:   Tokens.centerExpandedHeight

            currentIndex: {
                let panels = ["dashboard", "console", "media"]
                const idx = panels.indexOf(Globals.activeCenterPanel)
                return idx < 0 ? 0 : idx
            }

            DashboardWidget {
                id: dashboard
                width:  stack.width
                height: stack.height
            }
            ConsoleWidget {
                id: consoleView
                width:  stack.width
                height: stack.height
            }
            MediaWidget {
                id: media
                width:  stack.width
                height: stack.height
            }
        }
    }
}
