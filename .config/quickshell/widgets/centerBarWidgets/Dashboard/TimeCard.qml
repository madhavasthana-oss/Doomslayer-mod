// TimeCard.qml — live clock + date
import QtQuick
import QtQuick.Layouts
import "../../.."

Rectangle {
    id: root
    Layout.fillWidth: true
    implicitHeight: col.implicitHeight + 2 * Tokens.paddingV
    radius: Tokens.radiusMd
    color: Theme.bgSurface
    border.color: Theme.borderIdle
    border.width: Tokens.strokeWidth

    property string clockText: Qt.formatTime(new Date(), "hh:mm:ss")
    property string dateText:  Qt.formatDate(new Date(), "ddd · dd MMM yyyy")

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            root.clockText = Qt.formatTime(new Date(), "hh:mm:ss")
            root.dateText  = Qt.formatDate(new Date(), "ddd · dd MMM yyyy")
        }
    }

    ColumnLayout {
        id: col
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: Tokens.paddingH
        spacing: Tokens.spacingXss

        Text {
            text: "TIME"
            font.family: Theme.fontDisplay
            font.pixelSize: Tokens.fontSizeLabel
            color: Theme.accent
        }
        Text {
            Layout.fillWidth: true
            text: root.clockText
            font.family: Theme.fontMono
            font.pixelSize: Tokens.fontSizeLarge
            color: Theme.textPrimary
        }
        Text {
            Layout.fillWidth: true
            text: root.dateText
            font.family: Theme.fontMono
            font.pixelSize: Tokens.fontSizeSmall
            color: Theme.textSecondary
        }
    }
}
