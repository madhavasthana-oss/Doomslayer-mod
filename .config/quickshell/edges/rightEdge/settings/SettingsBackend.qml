// SettingsBackend.qml — brightness, kbd, audio, capture tools, nwg-look
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import "../../.."

Item {
    id: root

    property int brightness: 50       // percent 0–100
    property int kbdBrightness: 0     // 0–max
    property int kbdMax: 2
    property int volume: 0
    property bool muted: false
    property bool recording: Globals.screenRecording
    property string statusMsg: ""
    property string kbdDevice: "platform::kbd_backlight"

    signal requestClose()   // parent should collapse edge panel

    // ─── PipeWire sink ───────────────────────────────────────
    PwObjectTracker {
        id: sinkTracker
        objects: [Pipewire.defaultAudioSink]
    }
    readonly property var sinkAudio: sinkTracker.objects[0]?.audio ?? null

    function syncVolume() {
        const a = sinkAudio
        if (!a)
            return
        root.volume = Math.round(a.volume * 100)
        root.muted = a.muted
    }

    function setVolume(pct) {
        const a = sinkAudio
        if (!a)
            return
        a.volume = Math.max(0, Math.min(1.5, pct / 100))
        root.volume = Math.round(a.volume * 100)
    }

    function toggleMute() {
        const a = sinkAudio
        if (!a)
            return
        a.muted = !a.muted
        root.muted = a.muted
    }

    Connections {
        target: root.sinkAudio
        enabled: root.sinkAudio !== null
        ignoreUnknownSignals: true
        function onVolumeChanged() { root.syncVolume() }
        function onMutedChanged()  { root.syncVolume() }
    }

    Component.onCompleted: {
        brightQuery.running = true
        kbdQuery.running = true
        syncVolume()
    }

    // ─── Screen brightness ───────────────────────────────────
    function setBrightness(pct) {
        const v = Math.max(1, Math.min(100, Math.round(pct)))
        brightSet.pct = String(v) + "%"
        brightSet.running = true
        root.brightness = v
    }

    Process {
        id: brightQuery
        command: ["brightnessctl", "-m", "g"]
        // machine: device,class,current,percent,max
        stdout: StdioCollector {
            onStreamFinished: {
                // e.g. intel_backlight,backlight,48000,50%,96000
                const parts = text.trim().split(",")
                if (parts.length >= 4) {
                    const p = parseInt(parts[3])
                    if (!isNaN(p))
                        root.brightness = p
                }
            }
        }
    }

    Process {
        id: brightSet
        property string pct: "50%"
        command: ["brightnessctl", "set", pct]
        onExited: brightQuery.running = true
    }

    // ─── Keyboard backlight ──────────────────────────────────
    function setKbd(level) {
        const v = Math.max(0, Math.min(root.kbdMax, Math.round(level)))
        kbdSet.level = String(v)
        kbdSet.running = true
        root.kbdBrightness = v
    }

    function cycleKbd() {
        setKbd((root.kbdBrightness + 1) % (root.kbdMax + 1))
    }

    Process {
        id: kbdQuery
        command: ["brightnessctl", "-m", "-d", "platform::kbd_backlight", "g"]
        stdout: StdioCollector {
            onStreamFinished: {
                const parts = text.trim().split(",")
                // device,class,current,percent,max
                if (parts.length >= 5) {
                    root.kbdBrightness = parseInt(parts[2]) || 0
                    root.kbdMax = parseInt(parts[4]) || 2
                }
            }
        }
    }

    Process {
        id: kbdSet
        property string level: "0"
        command: ["brightnessctl", "-d", "platform::kbd_backlight", "set", level]
        onExited: kbdQuery.running = true
    }

    // ─── Appearance (nwg-look) ───────────────────────────────
    function launchLook() {
        root.statusMsg = "LAUNCHING NWG-LOOK"
        root.requestClose()
        // slight delay so panel can collapse first
        lookTimer.start()
    }

    Timer {
        id: lookTimer
        interval: Tokens.animMedium
        onTriggered: Quickshell.execDetached(["nwg-look"])
    }

    // ─── Screenshot (grim + slurp) ───────────────────────────
    function screenshot() {
        root.statusMsg = "SELECT REGION"
        root.requestClose()
        shotTimer.start()
    }

    Timer {
        id: shotTimer
        interval: Tokens.animMedium
        onTriggered: {
            Quickshell.execDetached([
                "bash", "-c",
                "mkdir -p \"$HOME/Pictures\" && "
                + "f=\"$HOME/Pictures/slayer-$(date +%Y%m%d-%H%M%S).png\" && "
                + "grim -g \"$(slurp)\" \"$f\" && notify-send Screenshot \"$f\""
            ])
        }
    }

    // ─── Screen record (wf-recorder + slurp) ─────────────────
    function toggleRecord() {
        if (Globals.screenRecording) {
            stopRecord.running = true
            return
        }
        root.statusMsg = "SELECT REGION TO RECORD"
        root.requestClose()
        recTimer.start()
    }

    Timer {
        id: recTimer
        interval: Tokens.animMedium
        onTriggered: {
            Globals.screenRecording = true
            Quickshell.execDetached([
                "bash", "-c",
                "mkdir -p \"$HOME/Videos\" && "
                + "f=\"$HOME/Videos/slayer-$(date +%Y%m%d-%H%M%S).mp4\" && "
                + "wf-recorder -g \"$(slurp)\" -f \"$f\"; "
                + "notify-send 'Recording saved' \"$f\""
            ])
        }
    }

    Process {
        id: stopRecord
        command: ["pkill", "-INT", "wf-recorder"]
        onExited: {
            Globals.screenRecording = false
            root.statusMsg = "RECORDING STOPPED"
        }
    }
}
