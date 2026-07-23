// CenterPanel.qml
import QtQuick
import QtQuick.Layouts
import "../.."
import "."

Item {
    id: root
    implicitHeight: mainCenterPanelLayout.implicitHeight
    implicitWidth:  mainCenterPanelLayout.implicitWidth

    readonly property var panelOrder: ["dashboard", "console", "media"]

    function switchCenterPanel(panel) {
        Globals.activeCenterPanel = panel
        Globals.lastCenterPanel = panel
        Qt.callLater(root.grabActiveFocus)
    }

    function cycleCenterPanel(delta) {
        const order = root.panelOrder
        let idx = order.indexOf(Globals.activeCenterPanel)
        if (idx < 0)
            idx = 0
        idx = (idx + delta + order.length) % order.length
        switchCenterPanel(order[idx])
    }

    function grabActiveFocus() {
        const panel = Globals.activeCenterPanel
        if (panel === "console")
            consoleView.grabListFocus()
        else
            root.forceActiveFocus()
    }

    // Left/Right cycle dashboard / console / media
    Keys.onPressed: (event) => {
        if (event.key === Qt.Key_Left) {
            root.cycleCenterPanel(-1)
            event.accepted = true
        } else if (event.key === Qt.Key_Right) {
            root.cycleCenterPanel(1)
            event.accepted = true
        } else if (event.key === Qt.Key_1) {
            root.switchCenterPanel("dashboard")
            event.accepted = true
        } else if (event.key === Qt.Key_2) {
            root.switchCenterPanel("console")
            event.accepted = true
        } else if (event.key === Qt.Key_3) {
            root.switchCenterPanel("media")
            event.accepted = true
        }
    }
    focus: true

    ColumnLayout {
        id: mainCenterPanelLayout

        CenterTabs {
            id: tabs
            Layout.leftMargin:  Tokens.paddingH
            Layout.rightMargin: Tokens.paddingH

            active: Globals.activeCenterPanel
            onSwitched: (panel) => root.switchCenterPanel(panel)
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

        // 3. Content panels --- fixed token footprint so token height toggles
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
