pragma Singleton
import QtQuick 2.15
import Quickshell

QtObject {
    readonly property int workspaceNumber: 7

    // Active panel tracker — single source of truth
    // Values: "" | "cpu" | "gpu" | "ram" | "bat" | "greeting"
    property string activePanel    : ""
    property string lastPanel      : "cpu"
    property bool consolePanelOpen : false
}