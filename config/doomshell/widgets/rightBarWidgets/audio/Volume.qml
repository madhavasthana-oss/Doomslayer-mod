import Quickshell.Services.Pipewire
import QtQuick

Item {
    id: audioStat
    property int volume: 0
    property bool muted: false

    PwObjectTracker {
        id: sinkTracker
        objects: [Pipewire.defaultAudioSink]
    }

    Timer {
        id: initTimer
        interval: 500
        repeat:   false
        running:  true
        onTriggered: {
            if (sinkTracker.objects[0]?.audio) {
                audioStat.volume = Math.round(sinkTracker.objects[0].audio.volume * 100)
                audioStat.muted  = sinkTracker.objects[0].audio.muted
                console.log("volume after delay:", audioStat.volume)
            }
        }
    }

    Connections {
        target: Pipewire
        function onDefaultAudioSinkChanged() {
            initTimer.start()
        }
    }

    Connections {
        target: sinkTracker.objects[0]?.audio ?? null
        function onVolumeChanged() {
            audioStat.volume = Math.round(sinkTracker.objects[0].audio.volume * 100)
        }
        function onMutedChanged() {
            audioStat.muted = sinkTracker.objects[0].audio.muted
        }
    }
}