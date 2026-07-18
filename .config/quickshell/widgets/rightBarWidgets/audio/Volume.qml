import Quickshell.Services.Pipewire
import QtQuick

Item {
    id: audioStat

    property int volume: 0        // true volume, can exceed 100 (e.g. up to 150)
    property bool muted: false
    property bool ready: false
    property string display: muted ? "M" : (volume + "%")

    property int barVolume: Math.min(volume, 100)
    property real barFraction: barVolume / 100

    // --- Startup init tuning ---
    property int initialDelayMs: 1000   // wait before even trying, gives PipeWire time to come up on boot
    property int retryIntervalMs: 500   // how often to retry after the initial delay
    property int maxRetries: 40         // ~20s of retrying after the initial delay before giving up
    property int retryCount: 0

    signal volumeModified(int volume, bool muted)

    PwObjectTracker {
        id: sinkTracker
        objects: [Pipewire.defaultAudioSink]
    }

    readonly property var currentAudio: sinkTracker.objects[0]?.audio ?? null

    function syncFromAudio() {
        const audio = currentAudio
        if (!audio)
            return false

        const vol = Math.round(audio.volume * 100)
        const isMuted = audio.muted

        if (vol <= 0)
            return false

        const changed = (vol !== audioStat.volume) || (isMuted !== audioStat.muted)

        audioStat.volume = vol
        audioStat.muted = isMuted

        if (changed)
            audioStat.volumeModified(vol, isMuted)

        return true
    }

    function initialize() {
        if (syncFromAudio()) {
            audioStat.ready = true
            audioStat.retryCount = 0
            retryTimer.stop()
        } else {
            audioStat.ready = false

            if (audioStat.retryCount >= audioStat.maxRetries) {
                console.warn("audioStat: gave up waiting for PipeWire default sink after "
                             + audioStat.retryCount + " retries")
                retryTimer.stop()
                return
            }

            audioStat.retryCount++
            retryTimer.start()
        }
    }

    // Initial "sleep" before the very first init attempt — lets PipeWire/WirePlumber
    // finish coming up on cold boot before we even ask for defaultAudioSink.
    Timer {
        id: startupTimer
        interval: audioStat.initialDelayMs
        repeat: false
        running: true
        onTriggered: audioStat.initialize()
    }

    // Ongoing retry loop, only used after the initial delay if the sink
    // still isn't ready (e.g. PipeWire took longer than initialDelayMs).
    Timer {
        id: retryTimer
        interval: audioStat.retryIntervalMs
        repeat: true
        running: false
        onTriggered: audioStat.initialize()
    }

    Connections {
        target: Pipewire
        function onDefaultAudioSinkChanged() {
            audioStat.retryCount = 0
            audioStat.initialize()
        }
    }

    Connections {
        target: audioStat.currentAudio
        enabled: audioStat.currentAudio !== null
        ignoreUnknownSignals: true

        function onVolumeChanged() {
            audioStat.syncFromAudio()
        }
        function onMutedChanged() {
            audioStat.syncFromAudio()
        }
    }

    // NOTE: Component.onCompleted no longer calls initialize() directly —
    // startupTimer handles the first attempt after initialDelayMs.
}