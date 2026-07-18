pragma Singleton
import QtQuick 2.15
import Quickshell

QtObject {
    readonly property int workspaceNumber: 7

    property string activePanel    : ""
    property string lastPanel      : "cpu"


    property string activeCenterPanel : ""
    property string lastCenterPanel   : "console"
}