// ---
//  Bar.qml
//  Unified rectangular top bar (replaces separate trapezoid windows).
//  Layout: Left (flex) | Center (hug) | Right (flex)
//  Equal flex on L/R keeps the center section screen-centered.
// ---

import QtQuick
import QtQuick.Layouts
import ".."

Item {
    id: bar
    clip: true

    // Section geometry in bar-local coords (== screen-x; bar is full-width).
    // mapToItem so we include RowLayout margins — raw child.x is layout-local.
    readonly property real leftSectionX: leftBarItem.mapToItem(bar, 0, 0).x
    readonly property real leftSectionW: leftBarItem.width
    readonly property real centerSectionX: centerBarItem.mapToItem(bar, 0, 0).x
    readonly property real centerSectionW: centerBarItem.width
    readonly property real rightSectionX: rightBarItem.mapToItem(bar, 0, 0).x
    readonly property real rightSectionW: rightBarItem.width

    // Single shared chrome for the whole top strip
    Rectangle {
        id: barBg
        anchors.fill: parent
        color: Qt.rgba(
            Theme.bgSurface.r,
            Theme.bgSurface.g,
            Theme.bgSurface.b,
            Theme.opacityBar
        )
    }

    // Accent underline (replaces trapezoid stroke)
    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: Math.max(1, Math.round(Tokens.strokeWidthActive))
        color: Theme.accent
        z: 1
    }

    RowLayout {
        id: row
        anchors.fill: parent
        anchors.leftMargin: Tokens.spacingXs
        anchors.rightMargin: Tokens.spacingXs
        spacing: Tokens.spacingXs

        // Left flexes; content stays left-aligned inside the section
        LeftBar {
            id: leftBarItem
            Layout.fillWidth: true
            Layout.preferredWidth: Tokens.leftWidth
            Layout.minimumWidth: Math.max(
                Tokens.preferredWidthNoGreeting * 2,
                // workspace row + separator + a little title room
                leftBarItem.wsRowWidth + Tokens.spacingMd * 2 + Tokens.spacingXl
            )
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignVCenter
        }

        // Center hugs content; equal L/R flex keeps it centered
        CenterBar {
            id: centerBarItem
            Layout.fillWidth: false
            Layout.preferredWidth: centerBarItem.implicitWidth
            Layout.maximumWidth: Math.min(
                Tokens.centerWidth,
                // never steal so much that L/R fall below their mins on common widths
                Math.max(Tokens.greetingWidth, bar.width * 0.4)
            )
            Layout.minimumWidth: Tokens.greetingWidth
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignVCenter
        }

        // Right flexes; content stays right-aligned inside the section
        RightBar {
            id: rightBarItem
            Layout.fillWidth: true
            Layout.preferredWidth: Tokens.rightWidth
            Layout.minimumWidth: Tokens.preferredWidthNoGreeting * 3
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignVCenter
        }
    }
}
