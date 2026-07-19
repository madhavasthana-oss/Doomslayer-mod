import QtQuick
import QtQuick.Layouts 1.15
import QtQuick.Controls 
import Quickshell
import "../../.."

Item {
    id: root
    implicitWidth: mainLayout.implicitWidth + 2 * Tokens.marginTop
    implicitHeight: mainLayout.implicitHeight + 2 * Tokens.marginTop
    visible: Globals.activeCenterPanel !== ""
    Rectangle {
        anchors.fill: parent
        id: bgDisplay
        radius: 10
        color:        Theme.bgConsole
        opacity:      Theme.opacityConsole
        border.color: Theme.borderConsole
        border.width: Tokens.strokeWidth
    }

    ColumnLayout {
        id: mainLayout
        anchors.fill: parent
        anchors.margins: {
            top: Tokens.spacingXss
        }
        
        Item {
            Layout.fillHeight: true
        }
    }
}