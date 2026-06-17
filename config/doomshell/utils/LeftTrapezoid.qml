// =============================================================
//  LeftTrapezoid.qml
//  DOOMSHELL — Command Throne
//  Semi 45° trapezoid. angleOffset == barHeight always.
//  Wider at top on one side, pinched at bottom. Parallel seam edges.
// =============================================================

import QtQuick 2.15
import QtQuick.Shapes 1.15
import ".."
Item {
    id: root

    // ---------------------------------------------------------
    //  PROPERTIES
    // ---------------------------------------------------------

    property real barWidth:    600
    property real barHeight:   75
    property real inset: Globals.barInset

    // True 45° — offset equals height exactly
    // Do not override this unless you want a different angle
    property real angleOffset: barHeight

    property real fillOpacity:  Globals.barOpacity
    property color fillColor:   Theme.bgSurface
    property color strokeColor: Theme.accent
    property real strokeWidth:  1.5

    property bool hovered:     false
    property bool alertActive: false

    width:  barWidth
    height: barHeight

    Shape {
        id: trapShape
        anchors.fill: parent
        layer.enabled: true
        layer.samples: 4

        ShapePath {
            // === FILL (this is what makes the trapezoid filled) ===
            fillColor: Qt.rgba(
                root.fillColor.r,
                root.fillColor.g,
                root.fillColor.b,
                root.fillOpacity
            )

            // === STROKE ===
            strokeColor: root.alertActive
                             ? "#CC2200"
                             : root.hovered
                                 ? "#FFCA80"
                                 : root.strokeColor
            strokeWidth: root.hovered
                             ? 2.0
                             : root.strokeWidth

            Behavior on strokeColor {
                ColorAnimation { duration: 120; easing.type: Easing.OutCubic }
            }
            Behavior on strokeWidth {
                NumberAnimation { duration: 120; easing.type: Easing.OutCubic }
            }
            
			startX: 0
			startY: 0
			
			PathLine { x: root.barWidth - root.angleOffset; y: 0              }
			PathLine { x: root.barWidth;                    y: root.barHeight }
			PathLine { x: 0;                                y: root.barHeight }
			PathLine { x: 0;                                y: 0              }

        }
    }

    // ---------------------------------------------------------
    //  INNER EMBER GLOW
    //  Inset 6px parallel to outer stroke.
    //  Gives the bar a heated-edge quality.
    //  Fades out when alert is active.
    // ---------------------------------------------------------

    // Shape {
    //     id: innerGlow
    //     anchors.fill: parent
    //     opacity: root.alertActive ? 0.0 : 0.30
    //     layer.enabled: true
    //     layer.samples: 4

    //     Behavior on opacity {
    //         NumberAnimation {
    //             duration: 220
    //             easing.type: Easing.OutCubic
    //         }
    //     }

    //     ShapePath {
    //         fillColor:   "transparent"
    //         strokeColor: "#FFCA80"
    //         strokeWidth: 0.6

    //         startX: inset
    //         startY: inset
            
    //         PathLine { x: root.barWidth - root.angleOffset - inset; y: inset                  }
    //         PathLine { x: root.barWidth - inset;                    y: root.barHeight - inset }
    //         PathLine { x: inset;                                    y: root.barHeight - inset }
    //         PathLine { x: inset;                                    y: inset                  }
    //     }
    // }

    // ---------------------------------------------------------
    //  ALERT PULSE
    //  Breathes when alertActive is true.
    //  Slow, deliberate — not a frantic flash.
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
