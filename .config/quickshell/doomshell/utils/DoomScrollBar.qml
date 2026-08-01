// DoomScrollBar.qml --- themed vertical scrollbar for ListView / Flickable
import QtQuick
import QtQuick.Controls
import ".."

ScrollBar {
    id: root

    // Always show when content overflows; hide when it fits
    policy: {
        // parent is the Flickable/ListView when used as ScrollBar.vertical:
        const f = parent
        if (!f)
            return ScrollBar.AsNeeded
        const ch = f.contentHeight !== undefined ? f.contentHeight : 0
        const h  = f.height !== undefined ? f.height : 0
        return (ch > h + 1) ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
    }

    width: Math.max(Tokens.borderXs + 1, Math.round(5 * Tokens.scale))
    padding: 1

    contentItem: Rectangle {
        implicitWidth: root.width - 2
        radius: Tokens.radiusSm
        color: Theme.accent
        opacity: root.hovered || root.pressed ? Theme.opacityVisible : Theme.opacityMuted
        Behavior on opacity {
            NumberAnimation { duration: Tokens.animFast; easing.type: Easing.OutCubic }
        }
    }

    background: Rectangle {
        implicitWidth: root.width
        radius: Tokens.radiusSm
        color: Theme.bgElevated
        opacity: Theme.opacityMuted
        visible: root.size < 1.0
    }
}
