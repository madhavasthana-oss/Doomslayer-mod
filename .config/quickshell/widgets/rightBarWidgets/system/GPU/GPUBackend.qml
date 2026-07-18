import Quickshell
import Quickshell.Io
import QtQuick
import "../../../.."

Item {
    id: gpuBackend

    // -------------------------------------------------
    //  Public API
    // -------------------------------------------------

    property bool   __is_ready__   : false
    property bool   __name_found__ : false
    property string __gpu_name__   : "Loading GPU" 
    property int    __gpu_usage__  : -1
    property int    __gpu_freq__   : -1

    readonly property int historyLength: 20

    property var __gpu_usage_history__: new Array(historyLength).fill(undefined)
    property var __gpu_freq_history__:  new Array(historyLength).fill(undefined)

    // -------------------------------------------------
    //  Sliding window helpers
    // -------------------------------------------------

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

    // -------------------------------------------------
    //  Startup GPU name detection (fires once on login)
    // -------------------------------------------------

    Timer {
        id:       nameDetectTimer
        interval: 100
        running:  !gpuBackend.__name_found__
        repeat:   false
        onTriggered: {
            if (!gpuBackend.__name_found__)
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
                    let fragmented_data    = output.split(":")
                    gpuBackend.__gpu_name__ = fragmented_data.slice(2).join(":").trim()
                }
                gpuBackend.__name_found__ = true
                gpuNameProc.running       = false
            }
        }
    }

    // -------------------------------------------------
    //  Polling
    // -------------------------------------------------

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

    // -------------------------------------------------
    //  Telemetry
    // -------------------------------------------------

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

                gpuBackend.__gpu_usage__ = usage

                if (!isNaN(freq))
                    gpuBackend.__gpu_freq__ = freq

                gpuBackend.pushHistory(usage, "__gpu_usage_history__")
                gpuBackend.pushHistory(freq, "__gpu_freq_history__")

                if (!gpuBackend.__is_ready__)
                    gpuBackend.__is_ready__ = true
            }
        }
    }
}