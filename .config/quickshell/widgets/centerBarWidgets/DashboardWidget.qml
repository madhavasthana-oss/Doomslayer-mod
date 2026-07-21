// DashboardWidget.qml — nested Row/ColumnLayouts; right column fully utilized
import QtQuick
import QtQuick.Layouts
import "../.."
import "Dashboard"

Item {
    id: root

    // Drive stack size from tokens; content adapts when height is toggled
    implicitWidth:  Tokens.centerSmallerWidth
    implicitHeight: Tokens.centerExpandedHeight

    RowLayout {
        id: mainRow
        anchors.fill: parent
        anchors.margins: Tokens.paddingH
        spacing: Tokens.spacingMd

        // ── LEFT: time + calendar ────────────────────────────
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredWidth: 1
            Layout.minimumWidth: Tokens.listPanelWidth
            spacing: Tokens.spacingSm

            TimeCard {
                Layout.fillWidth: true
            }

            CalendarCard {
                Layout.fillWidth: true
                Layout.fillHeight: true
            }
        }

        // ── MID: todo + notes ────────────────────────────────
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredWidth: 1
            Layout.minimumWidth: Tokens.listPanelWidth
            spacing: Tokens.spacingSm

            TodoCard {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredHeight: 1
            }

            NotesCard {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredHeight: 1
            }
        }

        // ── RIGHT: weather (week, fills) + uptime ────────────
        // No spacer — weather claim the remaining vertical space.
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredWidth: 1
            Layout.minimumWidth: Tokens.listPanelWidth
            spacing: Tokens.spacingSm

            WeatherCard {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredHeight: 1
            }

            UptimeCard {
                Layout.fillWidth: true
            }
        }
    }
}
