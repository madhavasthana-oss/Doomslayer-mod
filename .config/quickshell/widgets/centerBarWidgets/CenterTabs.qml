import QtQuick
import Quickshell
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell.Wayland
import Quickshell.Hyprland
import "../.."

Item {
 id: root

 property string active: Globals.activeCenterPanel

 implicitHeight:   Tokens.spacingXl
 Layout.fillWidth: true

 signal switched(string panel)

 RowLayout{
    
 }
}
