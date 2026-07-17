import QtQuick
import QtQuick.Layouts 1.15
import QtQuick.Controls 
import Quickshell
import "../../.."

Item {
    id: root
    implicitWidth: Globals.centerWidth - 2 * Globals.centerHeight
    implicitHeight: Globals.centerWidth * 1 / 2
    visible: Globals.consolePanelOpen
    Rectangle {
        id: bgDisplay
        anchors.fill: parent
        radius: 10
        color:        Theme.bgConsole
        opacity:      Theme.opacityConsole
        border.color: Theme.borderConsole
        border.width: Theme.strokeWidth
    }

    ColumnLayout {
        id: mainLayout
        anchors.fill: parent
        anchors.margins: {
            top: Globals.spacingXs * 2
        }
        spacing: Globals.spacingXs

        Text {
            id: headerText
            Layout.alignment: Qt.AlignHCenter       
            text: "CONSOLE"
            font.family: Theme.fontDisplay
            color:       Theme.textMuted
            font.pixelSize: Theme.fontSizeLarge
        }

        Item {
            Layout.fillHeight: true
        }
    }
}