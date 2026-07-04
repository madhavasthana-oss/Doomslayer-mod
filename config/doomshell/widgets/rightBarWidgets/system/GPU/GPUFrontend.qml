import QtQuick
import Quickshell
import Quickshell.Io
import QtQuick.Layouts
import "../../../.."
import "../../../../utils"
import "."

Item {

    id: gpuFrontend

    property var freqBars: []
    property var freqTargets: []
    property real freqFrame: 0

    width:  Globals.rightWidth
    height: Globals.rightWidth * 8 / 7

    Connections {
        target: gpu

        function on__Gpu_usage__Changed() {
            let usageText = gpu.__gpu_usage__ === -1 ? "[ PROBING ]" : gpu.__gpu_usage__ + "%"
            textAnimator.transitionTo(usageText)
            usageBoxAnimator.transitionTo(gpu.__gpu_usage__ === -1 ? "[ PROBING ]" : usageText)
        }

        function on__Gpu_freq__Changed() {
            let freqVal = gpu.__gpu_freq__
            freqAnimator.transitionTo(freqVal === -1 ? "[ PROBING ]" : String(freqVal))
            freqBoxAnimator.transitionTo(freqVal === -1 ? "[ PROBING ]" : String(freqVal))
        }
    }

    Process {
        id: nvtopProc
        command: [
            "ghostty",
            "-e",
            "nvtop"
        ]
    }

    GPUBackend {
        id: gpu
    }

    AnimatedText {
        id: textAnimator
        mode: AnimatedText.Mode.Scramble
        duration: 180
    }

    AnimatedText {
        id: freqAnimator
        mode: AnimatedText.Mode.Scramble
        duration: 180
    }

    AnimatedText {
        id: usageBoxAnimator
        mode: AnimatedText.Mode.Scramble
        duration: 180
    }

    AnimatedText {
        id: freqBoxAnimator
        mode: AnimatedText.Mode.Scramble
        duration: 180
    }

    Component.onCompleted: {
        let base = gpu.__gpu_freq__ > 0 ? gpu.__gpu_freq__ : 500

        for (let i = 0; i < 40; i++) {
            freqBars.push(base + (Math.random() - 0.5) * 40)
            freqTargets.push(base)
        }
        textAnimator.transitionTo("[ PROBING ]")
        freqAnimator.transitionTo(gpu.__gpu_freq__ === -1 ? "--" : String(gpu.__gpu_freq__))
        usageBoxAnimator.transitionTo(gpu.__gpu_usage__ === -1 ? "--%" : gpu.__gpu_usage__ + "%")
        freqBoxAnimator.transitionTo(gpu.__gpu_freq__ === -1 ? "--" : String(gpu.__gpu_freq__))
    }

    Timer {
        id: usageTextUpdater

        interval: 500
        running: true
        repeat: true

        property int lastValue: -1

        onTriggered: {
            let current = gpu.__gpu_usage__

            if (current === lastValue)
                return

            lastValue = current

            if (current === -1) {
                textAnimator.transitionTo("[ PROBING ]")
                usageBoxAnimator.transitionTo("[ PROBING ]")
            } else {
                textAnimator.transitionTo(current + "%")
                usageBoxAnimator.transitionTo(current + "%")
            }
        }
    }

    Timer {
        id: freqTextUpdater

        interval: 500
        running: true
        repeat: true

        property int lastValue: -999

        onTriggered: {
            let current = gpu.__gpu_freq__

            if (current === lastValue)
                return

            lastValue = current

            if (current === -1) {
                freqAnimator.transitionTo("[ PROBING ]")
                freqBoxAnimator.transitionTo("--") 
            } else {
                freqAnimator.transitionTo(String(current))
                freqBoxAnimator.transitionTo(String(current))
            }
        }
    }

    Timer {
        id: repaintTimer
        interval: 150
        running: gpu.__is_ready__
        repeat: true
        onTriggered: {
            freqFrame++
            let target = gpu.__gpu_freq__ > 0 ? gpu.__gpu_freq__ : 500
            for (let i = 0; i < 40; i++) {
                freqTargets[i] = target + (Math.random() - 0.5) * 30
                freqBars[i] = freqBars[i] + (freqTargets[i] - freqBars[i]) * 0.12
                            + (Math.random() - 0.5) * 5
            }
            usageCanvas.requestPaint()
            freqCanvas.requestPaint()
        }
    }

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

    ColumnLayout {
        anchors.fill:    parent
        anchors.margins: Theme.paddingH
        spacing:         Globals.inMostSpacing * 2

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
                        color:          modelData === "GPU" ? Theme.accent : "transparent"
                        opacity:        0.8
                    }

                    Text {
                        anchors.centerIn:   parent
                        text:               modelData
                        font.family:        Theme.fontDisplay
                        font.pixelSize:     Theme.fontSizeLabel
                        color:              modelData === "GPU" ? Theme.accent : Theme.textDim
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

        Text {
            id: gpuName

            Layout.fillWidth: true

            text:                gpu.__gpu_name__
            wrapMode:            Text.WordWrap
            horizontalAlignment: Text.AlignHCenter

            font.family:    Theme.fontDisplay
            font.pixelSize: Theme.fontSizeSmall

            color: Theme.accent
        }

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
                property int liveVal: gpu.__gpu_usage__
                text:           textAnimator.displayedText
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
                    let usage_history = gpu.__gpu_usage_history__.filter(v => v !== undefined)
                    ctx.clearRect(0, 0, w, h)

                    ctx.strokeStyle = Theme.borderIdle
                    ctx.lineWidth   = 0.5
                    ctx.setLineDash([2,5])

                    for (let pct of [0.25, 0.5, 0.75]) {
                        let drawAt = h * (1 - pct)
                        ctx.beginPath()
                        ctx.moveTo(0, drawAt)
                        ctx.lineTo(w, drawAt)
                        ctx.stroke()
                    }

                    ctx.setLineDash([])
                    ctx.fillStyle = Theme.textDim
                    ctx.font      = "bold " + Theme.fontSizeTiny + "px " + Theme.fontMono
                    ctx.fillText("100", 3, 10)
                    ctx.fillText("50",  3, h * 0.5 - 2)
                    ctx.fillText("0",   3, h - 3)

                    let num_pts = usage_history.length
                    const xget = i => i / (num_pts - 1) * w
                    const yget = v => h * (1 - v / 100)

                    let grad = ctx.createLinearGradient(0, 0, 0, h)
                    grad.addColorStop(0,   Qt.rgba(1, 0.27, 0, 0.55))
                    grad.addColorStop(0.6, Qt.rgba(1, 0.27, 0, 0.12))
                    grad.addColorStop(1,   Qt.rgba(1, 0.27, 0, 0.0))

                    ctx.beginPath()
                    ctx.moveTo(xget(0), h)
                    ctx.lineTo(xget(0), yget(usage_history[0]))

                    for (let idx = 1; idx < num_pts; idx++) {
                        let pt1 = [xget(idx - 1), yget(usage_history[idx - 1])]
                        let pt2 = [xget(idx), yget(usage_history[idx])]
                        let cx  = (pt1[0] + pt2[0]) / 2
                        ctx.bezierCurveTo(cx, pt1[1], cx, pt2[1], pt2[0], pt2[1])
                    }

                    ctx.lineTo(xget(num_pts - 1), h)
                    ctx.closePath()
                    ctx.fillStyle = grad
                    ctx.fill()

                    ctx.strokeStyle = Theme.accent
                    ctx.lineWidth   = 1.5
                    ctx.beginPath()
                    ctx.moveTo(xget(0), yget(usage_history[0]))

                    for (let idx = 1; idx < num_pts; idx++) {
                        let pt1 = [xget(idx - 1), yget(usage_history[idx - 1])]
                        let pt2 = [xget(idx), yget(usage_history[idx])]
                        let cx  = (pt1[0] + pt2[0]) / 2
                        ctx.bezierCurveTo(cx, pt1[1], cx, pt2[1], pt2[0], pt2[1])
                    }

                    ctx.stroke()

                    let lastX = xget(num_pts - 1)
                    let lastY = yget(usage_history[num_pts - 1])
                    ctx.beginPath()
                    ctx.arc(lastX, lastY, 3, 0, Math.PI * 2)
                    ctx.fillStyle = Theme.accent
                    ctx.fill()
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Text {
                text:               "FREQUENCY"
                font.family:        Theme.fontDisplay
                font.pixelSize:     Theme.fontSizeLabel
                color:              Theme.textMuted
                font.letterSpacing: 1.2
            }
            Item { Layout.fillWidth: true }
            Text {
                id: liveFreqLabel
                property int liveVal: gpu.__gpu_freq__
                text:           freqAnimator.displayedText
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
                id: freqCanvas
                anchors.fill: parent

                onPaint: {
                    let ctx = getContext("2d")
                    let w = width
                    let h = height
                    ctx.clearRect(0, 0, w, h)

                    let numBars = gpuFrontend.freqBars.length

                    let pad    = 4
                    let gap    = 2
                    let drawW  = w - pad * 2
                    let barW   = (drawW - gap * (numBars - 1)) / numBars
                    let maxFreq = 1000

                    for (let i = 0; i < numBars; i++) {
                        let v     = Math.max(0, Math.min(maxFreq, gpuFrontend.freqBars[i]))
                        let ratio = v / maxFreq
                        let barH  = ratio * (h - 8)
                        let x     = pad + i * (barW + gap)
                        let y     = h - barH

                        let pulse = Math.abs(Math.sin(gpuFrontend.freqFrame * 0.04 + i * 0.15))
                        let alpha = 0.45 + ratio * 0.55

                        ctx.fillStyle = Qt.rgba(1, (40 + pulse * 30) / 255, 0, alpha)
                        ctx.fillRect(x, y, barW, barH)

                        ctx.fillStyle = Qt.rgba(1, 0.78, 0.47, 0.6 + pulse * 0.4)
                        ctx.fillRect(x, y, barW, 2)
                    }
                }
            }
        }

        RowLayout {
            Rectangle {
                Layout.fillWidth: true
                height:           40
                color:            Theme.bgElevated
                radius:           5
                border.color:     Theme.borderIdle
                border.width:     1

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 1

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text:               "USAGE"
                        font.family:        Theme.fontDisplay
                        font.pixelSize:     Theme.fontSizeLabel
                        color:              Theme.textMuted
                        font.letterSpacing: 1.2
                    }
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text:           usageBoxAnimator.displayedText
                        font.family:    Theme.fontMono
                        font.pixelSize: Theme.fontSizeMedium
                        font.bold:      true
                        color:          gpu.__gpu_usage__ > 85 ? Theme.stateCritical
                                        : gpu.__gpu_usage__ > 60 ? Theme.stateWarning
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

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 1

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text:               "FREQUENCY"
                        font.family:        Theme.fontDisplay
                        font.pixelSize:     Theme.fontSizeLabel
                        color:              Theme.textMuted
                        font.letterSpacing: 1.2
                    }

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text:           freqBoxAnimator.displayedText
                        font.family:    Theme.fontMono
                        font.pixelSize: Theme.fontSizeMedium
                        font.bold:      true
                        color:          gpu.__gpu_freq__ > 1000 ? Theme.stateCritical
                                        : gpu.__gpu_freq__ > 600 ? Theme.stateWarning
                                        : Theme.accent
                    }
                }
            }
        }

        Rectangle {
            id:                     nvtopBtn
            Layout.fillWidth:       true
            Layout.preferredHeight: 28
            radius:                 6
            color:                  nvtopHover.containsMouse ? Theme.bgElevated : Theme.bgSurface
            border.color:           nvtopHover.containsMouse ? Theme.accent : Theme.borderIdle
            border.width:           nvtopHover.containsMouse ? Theme.strokeWidthActive : Theme.strokeWidth

            Behavior on color {
                ColorAnimation {
                    duration: Theme.animFast
                }
            }

            Behavior on border.color {
                ColorAnimation {
                    duration: Theme.animFast
                }
            }

            Text {
                anchors.centerIn:   parent
                text:               "◈  LAUNCH NVTOP"
                font.family:        Theme.fontDisplay
                font.pixelSize:     Theme.fontSizeLabel
                font.letterSpacing: 1.5
                color:              nvtopHover.containsMouse ? Theme.accent : Theme.textMuted
                Behavior on color   { ColorAnimation { duration: Theme.animFast } }
            }

            MouseArea {
                id:                 nvtopHover 
                anchors.fill:       parent
                hoverEnabled:       true
                onClicked:          nvtopProc.running = true
                cursorShape:        Qt.PointingHandCursor
            }
        }
    }
}