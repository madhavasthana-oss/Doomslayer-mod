// ConsoleWidget.qml
import QtQuick
import QtQuick.Layouts
import "../.."

Item {
    id: root

    // Match the sizing route used by system frontends (content drives panel size)
    implicitWidth:  Tokens.centerSmallerWidth
    implicitHeight: Tokens.centerExpandedHeight

    Text {
        anchors.centerIn: parent
        text: "THIS IS A CONSOLE"
        font.family: Theme.fontDisplay
        font.pixelSize: Tokens.fontSizeMedium
        color: Theme.textPrimary
        horizontalAlignment: Text.AlignHCenter
    }
}
