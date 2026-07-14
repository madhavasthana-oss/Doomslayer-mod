// SystemTabs.qml
import QtQuick
import QtQuick.Layouts
import "../.."

Item {
    id: root

    property string active: Globals.activePanel   // "cpu" | "gpu" | "ram"
    signal switched(string panel)

    height: 20
    Layout.fillWidth: true

    // Tab labels
    RowLayout {
        id: tabRow
        anchors.fill: parent
        spacing: 5

        Repeater {
            model: [
                { id: "cpu", label: "CPU" },
                { id: "gpu", label: "GPU" },
                { id: "ram", label: "RAM" }
            ]

            Item {
                Layout.fillWidth: true
                height: 20

                property bool isActive: modelData.id === root.active
                property string panelId: modelData.id

                Text {
                    anchors.centerIn: parent
                    text: modelData.label
                    font.family: Theme.fontDisplay
                    font.pixelSize: Theme.fontSizeLabel
                    color: isActive ? Theme.accent : Theme.textDim
                    font.letterSpacing: 1.2
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.switched(modelData.id)
                }
            }
        }
    }

    Item {
        Layout.fillHeight: true
    }
    // ───────────────────────────────────────────────
    // THE single animated underline (Caelestia style)
    // ───────────────────────────────────────────────
    Rectangle {
        id: underline
        height: 1
        color: Theme.accent
        opacity: 1
        radius: 0.5
        y: parent.height - height

        // Smooth movement
        Behavior on x     { NumberAnimation { duration: Theme.animFast; easing.type: Easing.OutCubic } }
        Behavior on width { NumberAnimation { duration: Theme.animFast; easing.type: Easing.OutCubic } }

        // Keep underline under the active tab
        property Item activeTab: {
            for (let i = 0; i < tabRow.children.length; i++) {
                if (tabRow.children[i].panelId === root.active)
                    return tabRow.children[i]
            }
            return null
        }

        x:     activeTab ? activeTab.x     : 0
        width: activeTab ? activeTab.width : 0
    }
}