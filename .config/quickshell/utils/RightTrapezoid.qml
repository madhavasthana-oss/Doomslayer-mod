// =============================================================
//  RightTrapezoid.qml
//  DOOMSHELL — Oracle
//  Semi 45° trapezoid. Flat right, angled left.
//  Mirror of LeftTrapezoid.
// =============================================================

import QtQuick 2.15
import QtQuick.Shapes 2.15
import ".."

Item {
    id: root

    // ---------------------------------------------------------
    //  PROPERTIES
    // ---------------------------------------------------------

    property real barWidth:    600
    property real barHeight:   75
    property real angleOffset: barHeight

    property real fillOpacity:  Theme.opacityBar
    property color fillColor:   Theme.bgSurface
    property color strokeColor: Theme.accent
    property real strokeWidth:  1.5

    property bool hovered:     false
    property bool alertActive: false

    width:  barWidth
    height: barHeight

    // ---------------------------------------------------------
    //  TRAPEZOID SHAPE
    //
    //  /____________]
    //
    //  startX: angleOffset   → top-left pulled RIGHT
    //  bottom-left: x=0      → kicks OUT left
    //  right edge: flat
    // ---------------------------------------------------------

    Shape {
        id: trapShape
        anchors.fill: parent
        layer.enabled: true
        layer.samples: 4

        ShapePath {
            fillColor: Qt.rgba(
                root.fillColor.r,
                root.fillColor.g,
                root.fillColor.b,
                root.fillOpacity
            )

            strokeColor: root.alertActive
                             ? "#CC2200"
                             : root.hovered
                                 ? "#FFCA80"
                                 : root.strokeColor
            strokeWidth: root.hovered ? 2.0 : root.strokeWidth

            Behavior on strokeColor {
                ColorAnimation { duration: 120; easing.type: Easing.OutCubic }
            }
            Behavior on strokeWidth {
                NumberAnimation { duration: 120; easing.type: Easing.OutCubic }
            }

            startX: root.angleOffset
            startY: 0

            PathLine { x: root.barWidth;       y: 0              }
            PathLine { x: root.barWidth;       y: root.barHeight }
            PathLine { x: 0;                   y: root.barHeight }
            PathLine { x: root.angleOffset;    y: 0              }
        }
    }

    // ---------------------------------------------------------
    //  INNER EMBER GLOW
    //  inset referenced as parent.inset inside PathLine children
    // ---------------------------------------------------------

    // Shape {
    //     id: innerGlow
    //     anchors.fill: parent
    //     opacity: root.alertActive ? 0.0 : 0.30
    //     layer.enabled: true
    //     layer.samples: 4

    //     Behavior on opacity {
    //         NumberAnimation { duration: 220; easing.type: Easing.OutCubic }
    //     }

    //     ShapePath {
    //         fillColor:   "transparent"
    //         strokeColor: "#FFCA80"
    //         strokeWidth: 0.6

    //         property real inset: Globals.barInset

    //         startX: root.angleOffset + parent.inset
    //         startY: parent.inset

    //         PathLine { x: root.barWidth - parent.inset; y: parent.inset                  }
    //         PathLine { x: root.barWidth - parent.inset; y: root.barHeight - parent.inset }
    //         PathLine { x: parent.inset;                 y: root.barHeight - parent.inset }
    //         PathLine { x: root.angleOffset + parent.inset; y: parent.inset              }
    //     }
    // }

    // ---------------------------------------------------------
    //  ALERT PULSE
    // ---------------------------------------------------------

    SequentialAnimation {
        id: alertPulse
        running: root.alertActive
        loops:   Animation.Infinite

        NumberAnimation {
            target:   trapShape
            property: "opacity"
            from:     1.0
            to:       0.4
            duration: 500
            easing.type: Easing.OutCubic
        }
        NumberAnimation {
            target:   trapShape
            property: "opacity"
            from:     0.4
            to:       1.0
            duration: 500
            easing.type: Easing.InCubic
        }
    }

    onAlertActiveChanged: {
        if (!alertActive) trapShape.opacity = 1.0
    }

    // ---------------------------------------------------------
    //  HOVER DETECTION
    // ---------------------------------------------------------

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: root.hovered = true
        onExited:  root.hovered = false
    }
}