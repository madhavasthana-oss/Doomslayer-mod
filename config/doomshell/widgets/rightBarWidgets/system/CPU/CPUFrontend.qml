import QtQuick
import Quickshell
import Quickshell.Io
import QtQuick.Layouts
import "../../../.."

Item {
    id: cpuFrontend

    width:  Globals.rightWidth
    height: Globals.rightWidth * 8 / 7

    opacity: Globals.active
    // ---------------------------------------------------------
    //  BACKEND
    // ---------------------------------------------------------

    CPUBackend { id: cpu }

    // ---------------------------------------------------------
    //  SELECTION STATE
    // ---------------------------------------------------------

    property int selectedCore: 0

    // ---------------------------------------------------------
    //  REPAINT TRIGGER
    // ---------------------------------------------------------

    Timer {
        id: repaintTimer
        interval: 150
        running:  cpu.__ready__
        repeat:   true
        onTriggered: {
            usageCanvas.requestPaint()
            tempCanvas.requestPaint()
        }
    }

    onSelectedCoreChanged: {
        usageCanvas.requestPaint()
        tempCanvas.requestPaint()
    }

    // ---------------------------------------------------------
    //  PANEL BACKGROUND
    // ---------------------------------------------------------

    Rectangle {
        id: panelBg
        anchors.fill: parent
        radius:       10
        color:        Theme.bgConsole
        opacity:      Theme.opacityConsole
        border.color: Theme.borderConsole
        border.width: Theme.strokeWidth
    }

    Rectangle {
        anchors.top:   parent.top
        anchors.left:  parent.left
        anchors.right: parent.right
        height:        0
        radius:        10
        color:         Theme.accent
        opacity:       0.55
    }

    // ---------------------------------------------------------
    //  MAIN LAYOUT
    // ---------------------------------------------------------

    ColumnLayout {
        anchors.fill:    parent
        anchors.margins: Theme.paddingH
        spacing:         Globals.inMostSpacing * 2

        // ---------------------------------------------------------
        //  TAB ROW
        // ---------------------------------------------------------

        RowLayout {
            Layout.fillWidth:       true
            Layout.preferredHeight: 20
            spacing:                0

            Repeater {
            
                model: ["CPU", "GPU", "RAM"]
                Item {
                    Layout.fillWidth: true
                    height:           20

                    Rectangle {
                        anchors.bottom: parent.bottom
                        anchors.left:   parent.left
                        anchors.right:  parent.right
                        height:         1
                        color:          modelData === "CPU" ? Theme.accent : "transparent"
                        opacity:        0.8
                    }

                    Text {
                        anchors.centerIn:   parent
                        text:               modelData
                        font.family:        Theme.fontDisplay
                        font.pixelSize:     Theme.fontSizeLabel
                        color:              modelData === "CPU" ? Theme.accent : Theme.textDim
                        font.letterSpacing: 1.2
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape:  Qt.PointingHandCursor
                        onClicked:    Globals.activePanel = modelData.toLowerCase()
                    } 
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height:           1
            color:            Theme.borderIdle
            opacity:          0.5
        }

        // ---------------------------------------------------------
        //  BODY — core list (left) + detail panel (right)
        // ---------------------------------------------------------

        RowLayout {
            Layout.fillWidth:  true
            Layout.fillHeight: true
            spacing:           5

            // -------------------------------------------------
            //  LEFT — core list
            // -------------------------------------------------

            Rectangle {
                Layout.preferredWidth: 108
                Layout.fillHeight:     true
                color:                 Theme.bgSurface
                radius:                6
                border.color:          Theme.borderIdle
                border.width:          Theme.strokeWidth

                Text {
                    id: coreListHeader
                    anchors.top:              parent.top
                    anchors.topMargin:        5
                    anchors.horizontalCenter: parent.horizontalCenter
                    text:                     "CORES"
                    font.family:              Theme.fontDisplay
                    font.pixelSize:           Theme.fontSizeLabel
                    color:                    Theme.textMuted
                    font.letterSpacing:       1.5
                }

                ListView {
                    id: coreList
                    anchors.top:          coreListHeader.bottom
                    anchors.left:         parent.left
                    anchors.right:        parent.right
                    anchors.bottom:       parent.bottom
                    anchors.topMargin:    4
                    anchors.leftMargin:   4
                    anchors.rightMargin:  4
                    anchors.bottomMargin: 4
                    spacing:              1
                    clip:                 true
                    currentIndex:         cpuFrontend.selectedCore

                    model: cpu.cores

                    delegate: Item {
                        width:  coreList.width
                        height: 22

                        property int   coreUsage: model.usage === -1 ? 0 : model.usage
                        property bool  isSelected: index === cpuFrontend.selectedCore
                        property color usageColor: coreUsage > 85 ? Theme.stateCritical
                                                 : coreUsage > 60 ? Theme.stateWarning
                                                 : Theme.stateSafe

                        Rectangle {
                            anchors.fill: parent
                            color:        isSelected ? Qt.rgba(1, 0.27, 0, 0.18) : "transparent"
                            radius:       3
                            border.color: isSelected ? Theme.accent : "transparent"
                            border.width: isSelected ? 1 : 0
                        }

                        Text {
                            id: coreLabel
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left:           parent.left
                            anchors.leftMargin:     5
                            text:                   "C" + model.idx
                            font.family:            Theme.fontDisplay
                            font.pixelSize:         Theme.fontSizeSmall
                            color:                  isSelected ? Theme.accent : Theme.textMuted
                        }

                        Item {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left:           coreLabel.right
                            anchors.leftMargin:     5
                            anchors.right:          usagePct.left
                            anchors.rightMargin:    3
                            height:                 4

                            Rectangle {
                                anchors.fill: parent
                                radius:       2
                                color:        Theme.bgElevated
                                opacity:      0.8
                            }

                            Rectangle {
                                width:  Math.max(2, parent.width * (coreUsage / 100))
                                height: parent.height
                                radius: 2
                                color:  usageColor
                                Behavior on width { NumberAnimation { duration: Theme.animFast } }
                            }
                        }

                        Text {
                            id: usagePct
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.right:          parent.right
                            anchors.rightMargin:    5
                            text:                   model.usage === -1 ? "--" : model.usage + "%"
                            font.family:            Theme.fontMono
                            font.pixelSize:         Theme.fontSizeTiny
                            color:                  usageColor
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked:    cpuFrontend.selectedCore = index
                        }
                    }
                }
            }

            // -------------------------------------------------
            //  RIGHT — detail panel
            // -------------------------------------------------

            ColumnLayout {
                Layout.fillWidth:  true
                Layout.fillHeight: true
                spacing:           Globals.inMostSpacing

                // USAGE GRAPH
                ColumnLayout {
                    Layout.fillWidth:  true
                    Layout.fillHeight: true
                    spacing:           3

                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            text:               "USAGE"
                            font.family:        Theme.fontDisplay
                            font.pixelSize:     Theme.fontSizeLabel
                            color:              Theme.textMuted
                            font.letterSpacing: 1.2
                        }
                        Item { Layout.fillWidth: true }
                        Text {
                            id: liveUsageLabel
                            property int liveVal: cpu.cores.count > 0
                                ? (cpu.cores.get(cpuFrontend.selectedCore)?.usage ?? -1) : -1
                            text:           liveVal === -1 ? "--%"  : liveVal + "%"
                            font.family:    Theme.fontMono
                            font.pixelSize: Theme.fontSizeSmall
                            color:          liveVal > 85 ? Theme.stateCritical
                                          : liveVal > 60 ? Theme.stateWarning
                                          : Theme.accent
                        }
                    }

                    Rectangle {
                        Layout.fillWidth:  true
                        Layout.fillHeight: true
                        color:             Theme.bgElevated
                        radius:            5
                        clip:              true
                        border.color:      Theme.borderIdle
                        border.width:      1

                        Canvas {
                            id: usageCanvas
                            anchors.fill: parent

                            onPaint: {
                                let ctx = getContext("2d")
                                let w   = width
                                let h   = height
                                let row = cpu.cores.count > 0
                                    ? cpu.cores.get(cpuFrontend.selectedCore) : null
                                let buf = (cpu.history[cpuFrontend.selectedCore]?.usage ?? [])
                                    .filter(v => v !== undefined)

                                ctx.clearRect(0, 0, w, h)

                                ctx.strokeStyle = Theme.borderIdle
                                ctx.lineWidth   = 0.5
                                ctx.setLineDash([2, 5])
                                ctx.globalAlpha = 0.5
                                for (let pct of [0.25, 0.5, 0.75]) {
                                    ctx.beginPath()
                                    ctx.moveTo(0, h * (1 - pct))
                                    ctx.lineTo(w, h * (1 - pct))
                                    ctx.stroke()
                                }
                                ctx.setLineDash([])
                                ctx.globalAlpha = 1

                                ctx.fillStyle = Theme.textDim
                                ctx.font      = "bold " + Theme.fontSizeTiny + "px " + Theme.fontMono
                                ctx.fillText("100", 3, 10)
                                ctx.fillText("50",  3, h * 0.5 - 2)
                                ctx.fillText("0",   3, h - 3)

                                if (buf.length < 2) return

                                let pts = buf.length
                                function xAt(i) { return (i / (pts - 1)) * w }
                                function yAt(v) { return h - (v / 100) * h }

                                let grad = ctx.createLinearGradient(0, 0, 0, h)
                                grad.addColorStop(0,   Qt.rgba(1, 0.27, 0, 0.55))
                                grad.addColorStop(0.6, Qt.rgba(1, 0.27, 0, 0.12))
                                grad.addColorStop(1,   Qt.rgba(1, 0.27, 0, 0.0))

                                ctx.beginPath()
                                ctx.moveTo(xAt(0), h)
                                ctx.lineTo(xAt(0), yAt(buf[0]))
                                for (let i = 1; i < pts; i++) {
                                    let x0 = xAt(i - 1), y0 = yAt(buf[i - 1])
                                    let x1 = xAt(i),     y1 = yAt(buf[i])
                                    let cx  = (x0 + x1) / 2
                                    ctx.bezierCurveTo(cx, y0, cx, y1, x1, y1)
                                }
                                ctx.lineTo(xAt(pts - 1), h)
                                ctx.closePath()
                                ctx.fillStyle = grad
                                ctx.fill()

                                ctx.strokeStyle = Theme.accent
                                ctx.lineWidth   = 1.5
                                ctx.beginPath()
                                ctx.moveTo(xAt(0), yAt(buf[0]))
                                for (let i = 1; i < pts; i++) {
                                    let x0 = xAt(i - 1), y0 = yAt(buf[i - 1])
                                    let x1 = xAt(i),     y1 = yAt(buf[i])
                                    let cx  = (x0 + x1) / 2
                                    ctx.bezierCurveTo(cx, y0, cx, y1, x1, y1)
                                }
                                ctx.stroke()

                                let lastX = xAt(pts - 1)
                                let lastY = yAt(buf[pts - 1])
                                ctx.beginPath()
                                ctx.arc(lastX, lastY, 3, 0, Math.PI * 2)
                                ctx.fillStyle = Theme.accent
                                ctx.fill()
                            }
                        }
                    }
                }

                // TEMP GRAPH
                ColumnLayout {
                    Layout.fillWidth:  true
                    Layout.fillHeight: true
                    spacing:           3

                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            text:               "TEMP"
                            font.family:        Theme.fontDisplay
                            font.pixelSize:     Theme.fontSizeLabel
                            color:              Theme.textMuted
                            font.letterSpacing: 1.2
                        }
                        Item { Layout.fillWidth: true }
                        Text {
                            id: liveTempLabel
                            property int liveVal: cpu.cores.count > 0
                                ? (cpu.cores.get(cpuFrontend.selectedCore)?.temp ?? -1) : -1
                            text:           liveVal === -1 ? "--°C" : liveVal + "°C"
                            font.family:    Theme.fontMono
                            font.pixelSize: Theme.fontSizeSmall
                            color:          liveVal > 85 ? Theme.stateCritical
                                          : liveVal > 70 ? Theme.stateWarning
                                          : Theme.accentWarm
                        }
                    }

                    Rectangle {
                        Layout.fillWidth:  true
                        Layout.fillHeight: true
                        color:             Theme.bgElevated
                        radius:            5
                        clip:              true
                        border.color:      Theme.borderIdle
                        border.width:      1

                        Canvas {
                            id: tempCanvas
                            anchors.fill: parent

                            onPaint: {
                                let ctx  = getContext("2d")
                                let w    = width
                                let h    = height
                                let row  = cpu.cores.count > 0
                                    ? cpu.cores.get(cpuFrontend.selectedCore) : null
                                let buf = (cpu.history[cpuFrontend.selectedCore]?.temp ?? [])
                                    .filter(v => v !== undefined)   
                                let tMin = 20
                                let tMax = 100

                                ctx.clearRect(0, 0, w, h)

                                ctx.strokeStyle = Theme.borderIdle
                                ctx.lineWidth   = 0.5
                                ctx.setLineDash([2, 5])
                                ctx.globalAlpha = 0.5
                                for (let t of [50, 75]) {
                                    let gy = h - ((t - tMin) / (tMax - tMin)) * h
                                    ctx.beginPath()
                                    ctx.moveTo(0, gy)
                                    ctx.lineTo(w, gy)
                                    ctx.stroke()
                                }
                                ctx.setLineDash([])
                                ctx.globalAlpha = 1.0

                                ctx.fillStyle = Theme.textDim
                                ctx.font      = "bold " + Theme.fontSizeTiny + "px " + Theme.fontMono
                                ctx.fillText(tMax + "°", 3, 10)
                                ctx.fillText("75°",      3, h - ((75 - tMin) / (tMax - tMin)) * h - 3)
                                ctx.fillText(tMin + "°", 3, h - 3)

                                if (buf.length < 2) return

                                let pts    = buf.length
                                let latest = buf[pts - 1]

                                function xAt(i) { return (i / (pts - 1)) * w }
                                function yAt(v) { return h - ((v - tMin) / (tMax - tMin)) * h }

                                let lineColor = latest > 85 ? Theme.stateCritical
                                             : latest > 70 ? Theme.stateWarning
                                             : Theme.accentWarm

                                let grad = ctx.createLinearGradient(0, 0, 0, h)
                                if (latest > 85) {
                                    grad.addColorStop(0, Qt.rgba(0.8,  0.13, 0,   0.55))
                                    grad.addColorStop(1, Qt.rgba(0.8,  0.13, 0,   0.0))
                                } else if (latest > 70) {
                                    grad.addColorStop(0, Qt.rgba(1.0,  0.79, 0.5, 0.5))
                                    grad.addColorStop(1, Qt.rgba(1.0,  0.79, 0.5, 0.0))
                                } else {
                                    grad.addColorStop(0, Qt.rgba(1.0,  0.79, 0.5, 0.4))
                                    grad.addColorStop(1, Qt.rgba(1.0,  0.79, 0.5, 0.0))
                                }

                                ctx.beginPath()
                                ctx.moveTo(xAt(0), h)
                                ctx.lineTo(xAt(0), yAt(buf[0]))
                                for (let i = 1; i < pts; i++) {
                                    let x0 = xAt(i - 1), y0 = yAt(buf[i - 1])
                                    let x1 = xAt(i),     y1 = yAt(buf[i])
                                    let cx  = (x0 + x1) / 2
                                    ctx.bezierCurveTo(cx, y0, cx, y1, x1, y1)
                                }
                                ctx.lineTo(xAt(pts - 1), h)
                                ctx.closePath()
                                ctx.fillStyle = grad
                                ctx.fill()

                                ctx.strokeStyle = lineColor
                                ctx.lineWidth   = 1.5
                                ctx.beginPath()
                                ctx.moveTo(xAt(0), yAt(buf[0]))
                                for (let i = 1; i < pts; i++) {
                                    let x0 = xAt(i - 1), y0 = yAt(buf[i - 1])
                                    let x1 = xAt(i),     y1 = yAt(buf[i])
                                    let cx  = (x0 + x1) / 2
                                    ctx.bezierCurveTo(cx, y0, cx, y1, x1, y1)
                                }
                                ctx.stroke()

                                ctx.beginPath()
                                ctx.arc(xAt(pts - 1), yAt(latest), 3, 0, Math.PI * 2)
                                ctx.fillStyle = lineColor
                                ctx.fill()
                            }
                        }
                    }
                }

                // STATS ROW
                RowLayout {
                    Layout.fillWidth:       true
                    Layout.preferredHeight: 40
                    spacing:                8

                    Rectangle {
                        Layout.fillWidth: true
                        height:           40
                        color:            Theme.bgElevated
                        radius:           5
                        border.color:     Theme.borderIdle
                        border.width:     1

                        property int liveUsage: cpu.cores.count > 0
                            ? (cpu.cores.get(cpuFrontend.selectedCore)?.usage ?? -1) : -1

                        Column {
                            anchors.centerIn: parent 
                            spacing:          1

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text:               "USAGE"
                                font.family:        Theme.fontDisplay
                                font.pixelSize:     Theme.fontSizeLabel
                                color:              Theme.textMuted
                                font.letterSpacing: 1.2
                            }
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text:           parent.parent.liveUsage === -1 ? "--%"
                                                    : parent.parent.liveUsage + "%"
                                font.family:    Theme.fontMono
                                font.pixelSize: Theme.fontSizeMedium
                                font.bold:      true
                                color:          parent.parent.liveUsage > 85 ? Theme.stateCritical
                                              : parent.parent.liveUsage > 60 ? Theme.stateWarning
                                              : Theme.accent
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height:           40
                        color:            Theme.bgElevated
                        radius:           5
                        border.color:     Theme.borderIdle
                        border.width:     1

                        property int liveTemp: cpu.cores.count > 0
                            ? (cpu.cores.get(cpuFrontend.selectedCore)?.temp ?? -1) : -1

                        Column {
                            anchors.centerIn: parent
                            spacing:          1

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text:               "TEMP"
                                font.family:        Theme.fontDisplay
                                font.pixelSize:     Theme.fontSizeLabel
                                color:              Theme.textMuted
                                font.letterSpacing: 1.2
                            }
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text:           parent.parent.liveTemp === -1 ? "--°C"
                                                    : parent.parent.liveTemp + "°C"
                                font.family:    Theme.fontMono
                                font.pixelSize: Theme.fontSizeMedium
                                font.bold:      true
                                color:          parent.parent.liveTemp > 85 ? Theme.stateCritical
                                              : parent.parent.liveTemp > 70 ? Theme.stateWarning
                                              : Theme.accentWarm
                            }
                        }
                    }
                }
            }
        }

        // ---------------------------------------------------------
        //  LAUNCH BTOP BUTTON
        // ---------------------------------------------------------

        Rectangle {
            id: btopBtn
            Layout.fillWidth:       true
            Layout.preferredHeight: 28
            radius:                 6
            color:                  btopHover.containsMouse ? Theme.bgElevated : Theme.bgSurface
            border.color:           btopHover.containsMouse ? Theme.accent : Theme.borderIdle
            border.width:           btopHover.containsMouse ? Theme.strokeWidthActive : Theme.strokeWidth

            Behavior on color        { ColorAnimation { duration: Theme.animFast } }
            Behavior on border.color { ColorAnimation { duration: Theme.animFast } }

            Text {
                anchors.centerIn:   parent
                text:               "◈  LAUNCH BTOP"
                font.family:        Theme.fontDisplay
                font.pixelSize:     Theme.fontSizeLabel
                font.letterSpacing: 1.5
                color:              btopHover.containsMouse ? Theme.accent : Theme.textMuted
                Behavior on color   { ColorAnimation { duration: Theme.animFast } }
            }

            MouseArea {
                id:           btopHover
                anchors.fill: parent
                hoverEnabled: true
                onClicked:    btopProc.running = true
                cursorShape:  Qt.PointingHandCursor
            }
        }
    }

    Process {
        id:      btopProc
        command: ["ghostty", "-e", "btop", "--force-utf"]
    }
}
