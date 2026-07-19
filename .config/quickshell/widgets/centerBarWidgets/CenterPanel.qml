import QtQuick
import Quickshell
import QtQuick.Layouts
import Quickshell.Wayland
import "../.."
Item{
    id: root
    implicitHeight: mainCenterPanelLayout.implicitHeight 
    implicitWidth:  mainCenterPanelLayout.implicitWidth

    ColumnLayout{
        id:mainCenterPanelLayout
        CenterTabs {
            
        }
    }
}