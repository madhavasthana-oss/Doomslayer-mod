import Quickshell
import Quickshell.Io
import QtQuick
import "../../../.."

Item {
    id: gpuBackend

    // ---
    //  Public API
    // ---

    property bool   isReady   : false
    property bool   nameFound : false
    property string gpuName   : "Loading GPU" 
    property int    gpuUsage  : -1
    property int    gpuFreq   : -1

    readonly property int historyLength: 20

    property var gpuUsageHistory: new Array(historyLength).fill(undefined)
    property var gpuFreqHistory:  new Array(historyLength).fill(undefined)

    // ---
    //  Sliding window helpers
    // ---

    function getEarliestUndefined(buffer) {
        let nextEntry = 1
        for (let i = -1; i >= -historyLength; i--) {
            let val = buffer[buffer.length + i]
            if (val === undefined) {
                nextEntry = i
            } else {
                break
            }
        }
        return nextEntry
    }

    function pushHistory(value, propertyName) {
        let buf = gpuBackend[propertyName].slice()

        let nextEntry = getEarliestUndefined(buf)

        if (nextEntry === 1) {
            buf = buf.slice(1)
            buf.push(value)
        } else {
            buf[buf.length + nextEntry] = value
        }

        gpuBackend[propertyName] = buf
    }

    // ---
    //  Startup GPU name detection (fires once on login)
    // ---

    Timer {
        id:       nameDetectTimer
        interval: 100
        running:  !gpuBackend.nameFound
        repeat:   false
        onTriggered: {
            if (!gpuBackend.nameFound)
                gpuNameProc.running = true
        }
    }

    Process {
        id:      gpuNameProc
        running: false
        command: ["sh", "-c", "lspci | grep -Ei 'vga|3d|display' | head -n1"]
        stdout: StdioCollector {
            onStreamFinished: {
                let output = text.trim()
                if (output.length > 0) {
                    let fragmentedData    = output.split(":")
                    gpuBackend.gpuName = fragmentedData.slice(2).join(":").trim()
                }
                gpuBackend.nameFound = true
                gpuNameProc.running       = false
            }
        }
    }

    // ---
    //  Polling
    // ---

    Timer {
        id:       detector
        interval: 500
        running:  true
        repeat:   true
        onTriggered: {
            if (!gpuProc.running)
                gpuProc.running = true
        }
    }

    // ---
    //  Telemetry
    // ---

    Process {
        id:      gpuProc
        running: false
        command: [
            "turbostat",
            "--Summary",
            "--quiet",
            "--show", "GFX%rc6,GFXMHz",
            "--no-msr",
            "--no-perf",
            "-n", "1"
        ]
        stdout: StdioCollector {
            onStreamFinished: {
                let lines = text.trim().split("\n")
                if (lines.length < 2) return

                let data = lines[1].trim().split(/\s+/)
                if (data.length < 2) return

                let rc6  = parseFloat(data[0])
                let freq = parseInt(data[1])
                if (isNaN(rc6)) return

                let usage = Math.max(0, Math.min(100, Math.round(100 - rc6)))

                gpuBackend.gpuUsage = usage

                if (!isNaN(freq))
                    gpuBackend.gpuFreq = freq

                gpuBackend.pushHistory(usage, "gpuUsageHistory")
                gpuBackend.pushHistory(freq, "gpuFreqHistory")

                if (!gpuBackend.isReady)
                    gpuBackend.isReady = true
            }
        }
    }
}