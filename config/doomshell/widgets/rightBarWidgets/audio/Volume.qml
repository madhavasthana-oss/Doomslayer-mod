import Quickshell.Services.Pipewire
import QtQuick

Item {
    id: audioStat
    property int volume: 0
    property bool muted: false
    signal ready
    Component.onCompleted: {
        initialize()
    }
    PwObjectTracker {
        id: sinkTracker
        objects: [Pipewire.defaultAudioSink]
    }
    function initialize() {
        const sink = Pipewire.defaultAudioSink

        if (!sink || !sink.audio)
            return

        audioStat.volume = Math.round(sink.audio.volume * 100)
        audioStat.muted = sink.audio.muted
    }
    Timer {
        id: initTimer
        interval: 500
        repeat:   true
        running:  true
        onTriggered: {
            if (sinkTracker.objects[0]?.audio) {
                let vol    = Math.round(sinkTracker.objects[0].audio.volume * 100)
                let muted  = sinkTracker.objects[0].audio.muted
                if (vol > 0 && !muted) {
                    audioStat.volume = vol
                    audioStat.muted  = muted
                    audioStat.ready()
                    initTimer.stop()
                }
            }
        }
    }

    Connections {
        target: Pipewire

        function onDefaultAudioSinkChanged() {
            initialize()
        }
    }

    Connections {
       target: sinkTracker.objects[0] ?? null

        function onVolumeChanged() {
            audioStat.volume = Math.round(sinkTracker.objects[0].audio.volume * 100)
            audioStat.muted = sinkTracker.objects[0].audio.muted
        }
    }
}