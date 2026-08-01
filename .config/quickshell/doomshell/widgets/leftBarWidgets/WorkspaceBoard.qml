// WorkspaceBoard.qml --- mini-desktops + drag-drop
// Architecture from illogical-impulse / quickshell-overview OverviewWidget:
//   1. Workspace tiles with DropArea (track draggingTargetWorkspace onEntered)
//   2. Flat windowSpace layer above tiles (all chips share one parent — no reparent)
//   3. MouseArea.drag.target + Drag.active on each chip
//   4. On release: WorkspaceHub.moveToWorkspace(addr, target) via hl.dsp.window.move
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import "../.."
import "../../utils"

Item {
    id: root
    implicitWidth:  Tokens.workspaceBoardWidth
    implicitHeight: Tokens.workspaceBoardHeight
    clip: true

    readonly property int wsCount: Globals.workspaceNumber
    readonly property int cols: Tokens.workspaceBoardCols
    readonly property int rows: Math.ceil(wsCount / cols)
    readonly property int screenW: Math.max(1, WorkspaceHub.screenW)
    readonly property int screenH: Math.max(1, WorkspaceHub.screenH)
    readonly property real screenAspect: screenW / Math.max(1, screenH)
    readonly property int iconSz: Tokens.workspaceBoardIcon
    readonly property int gap: Tokens.spacingSm

    // Overview-style DnD state
    property int draggingFromWorkspace: -1
    property int draggingTargetWorkspace: -1
    property string draggingAddress: ""
    property bool isDragging: draggingAddress.length > 0

    // Absorb clicks so the dim overlay behind the card doesn't steal them
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.AllButtons
        onPressed: (mouse) => { mouse.accepted = true }
    }

    Rectangle {
        anchors.fill: parent
        radius: Tokens.radiusXl
        color: Qt.rgba(Theme.bgConsole.r, Theme.bgConsole.g, Theme.bgConsole.b, Theme.opacityConsole)
        border.color: Theme.borderActive
        border.width: Math.max(Tokens.borderXss, Math.round(Tokens.strokeWidthActive))
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Tokens.paddingH
        spacing: Tokens.spacingSm

        RowLayout {
            Layout.fillWidth: true
            spacing: Tokens.spacingSm

            Text {
                text: "WORKSPACE BOARD"
                font.family: Theme.fontDisplay
                font.pixelSize: Tokens.fontSizeLabel
                color: Theme.accent
            }
            Text {
                Layout.fillWidth: true
                text: root.isDragging
                    ? ("drop on a desktop  ·  target WS "
                       + (root.draggingTargetWorkspace > 0
                          ? String(root.draggingTargetWorkspace) : "—"))
                    : ("drag windows between mini-desktops  ·  "
                       + root.wsCount + " workspaces")
                font.family: Theme.fontMono
                font.pixelSize: Tokens.fontSizeTiny
                color: Theme.textDim
                elide: Text.ElideRight
            }
            Text {
                text: "↻"
                font.pixelSize: Tokens.fontSizeSmall
                color: refMouse.containsMouse ? Theme.accent : Theme.textDim
                MouseArea {
                    id: refMouse
                    anchors.fill: parent
                    anchors.margins: -Tokens.spacingXs
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: WorkspaceHub.refresh()
                }
            }
            Rectangle {
                Layout.preferredHeight: Tokens.actionBtnHeight
                Layout.preferredWidth: closeLbl.implicitWidth + 2 * Tokens.paddingH
                radius: Tokens.radiusSm
                color: closeMouse.containsMouse ? Theme.bgElevated : Theme.bgSurface
                border.color: Theme.borderIdle
                border.width: Tokens.strokeWidth
                Text {
                    id: closeLbl
                    anchors.centerIn: parent
                    text: "CLOSE"
                    font.family: Theme.fontDisplay
                    font.pixelSize: Tokens.fontSizeLabel
                    color: Theme.textPrimary
                }
                MouseArea {
                    id: closeMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Globals.closeWorkspaceBoard()
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: Tokens.strokeWidth
            color: Theme.borderIdle
            opacity: 0.5
        }

        // Grid host — tiles + flat window layer
        Item {
            id: gridHost
            Layout.fillWidth: true
            Layout.fillHeight: true

            readonly property int hGap: root.gap
            readonly property int vGap: root.gap
            readonly property int cellW: Math.max(40, Math.floor(
                (width - hGap * (root.cols - 1)) / root.cols))
            readonly property int headerH: Tokens.listRowHeight
            readonly property int footerH: Tokens.listRowHeight
            readonly property int miniH: Math.max(
                Tokens.statBoxHeight,
                Math.floor(cellW / root.screenAspect))
            readonly property int cellH: headerH + miniH + footerH
                + Tokens.spacingXss * 2
            readonly property int gridW: cellW * root.cols + hGap * (root.cols - 1)
            readonly property int gridH: cellH * root.rows + vGap * (root.rows - 1)

            // Geometry helpers for flat window placement (overview pattern)
            function cellX(wsId) {
                const i = wsId - 1
                return (i % root.cols) * (cellW + hGap)
            }
            function cellY(wsId) {
                const i = wsId - 1
                return Math.floor(i / root.cols) * (cellH + vGap)
            }
            function miniX(wsId) {
                return cellX(wsId)
            }
            function miniY(wsId) {
                return cellY(wsId) + headerH + Tokens.spacingXss
            }
            function miniWidth() { return cellW }
            function miniHeight() { return miniH }

            Item {
                id: grid
                width:  gridHost.gridW
                height: gridHost.gridH
                anchors.centerIn: parent

                // --- Layer 1: workspace tiles + DropAreas (under windows) ---
                Repeater {
                    model: root.wsCount

                    Item {
                        id: desk
                        property int wsId: index + 1
                        property bool isFocused: WorkspaceHub.focusedWorkspaceId === wsId
                        property bool dropHover: root.draggingTargetWorkspace === wsId
                            && root.isDragging
                        property int clientCount: {
                            // Depend on clientsByWorkspace so count updates
                            const _ = WorkspaceHub.clientsByWorkspace
                            return WorkspaceHub.clientsOn(desk.wsId).length
                        }

                        width:  gridHost.cellW
                        height: gridHost.cellH
                        x: gridHost.cellX(wsId)
                        y: gridHost.cellY(wsId)
                        z: 0

                        ColumnLayout {
                            anchors.fill: parent
                            spacing: Tokens.spacingXss

                            RowLayout {
                                Layout.fillWidth: true
                                Layout.preferredHeight: gridHost.headerH
                                Text {
                                    text: "WS " + desk.wsId
                                    font.family: Theme.fontDisplay
                                    font.pixelSize: Tokens.fontSizeLabel
                                    color: desk.isFocused ? Theme.accent : Theme.textDim
                                }
                                Item { Layout.fillWidth: true }
                                Text {
                                    text: String(desk.clientCount)
                                    font.family: Theme.fontMono
                                    font.pixelSize: Tokens.fontSizeTiny
                                    color: Theme.textMuted
                                }
                            }

                            // Mini desktop bezel
                            Rectangle {
                                id: bezel
                                Layout.fillWidth: true
                                Layout.preferredHeight: gridHost.miniH
                                Layout.maximumHeight: gridHost.miniH
                                radius: Tokens.radiusMd
                                color: Theme.bgPrimary
                                border.color: desk.dropHover ? Theme.accent
                                            : (desk.isFocused ? Theme.borderActive : Theme.borderIdle)
                                border.width: desk.dropHover
                                    ? Math.max(2, Tokens.strokeWidthActive)
                                    : Tokens.strokeWidth
                                clip: true

                                // Drop target (overview: onEntered tracks target ws)
                                DropArea {
                                    anchors.fill: parent
                                    onEntered: (drag) => {
                                        root.draggingTargetWorkspace = desk.wsId
                                        drag.accept(Qt.MoveAction)
                                    }
                                    onExited: {
                                        if (root.draggingTargetWorkspace === desk.wsId)
                                            root.draggingTargetWorkspace = -1
                                    }
                                }

                                // Click empty desktop → focus workspace
                                MouseArea {
                                    anchors.fill: parent
                                    z: -1
                                    acceptedButtons: Qt.LeftButton
                                    onClicked: {
                                        if (!root.isDragging)
                                            WorkspaceHub.switchToWorkspace(desk.wsId)
                                    }
                                }

                                Rectangle {
                                    anchors.fill: parent
                                    anchors.margins: Tokens.workspaceMiniPad
                                    radius: Tokens.radiusSm
                                    color: Theme.bgConsole
                                    border.color: Theme.borderIdle
                                    border.width: Tokens.strokeWidth

                                    Text {
                                        anchors.centerIn: parent
                                        // Only show "empty" when not dragging over
                                        visible: desk.clientCount === 0 && !desk.dropHover
                                        text: "empty"
                                        font.family: Theme.fontMono
                                        font.pixelSize: Tokens.fontSizeTiny
                                        color: Theme.textDim
                                    }
                                }
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: gridHost.footerH
                                radius: Tokens.radiusSm
                                color: focusBtn.containsMouse ? Theme.bgElevated : "transparent"
                                border.color: desk.isFocused ? Theme.stateSafe : Theme.borderIdle
                                border.width: Tokens.strokeWidth

                                Text {
                                    anchors.centerIn: parent
                                    text: desk.isFocused ? "ACTIVE" : "FOCUS"
                                    font.family: Theme.fontDisplay
                                    font.pixelSize: Tokens.fontSizeLabel
                                    color: desk.isFocused ? Theme.stateSafe : Theme.textMuted
                                }
                                MouseArea {
                                    id: focusBtn
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: WorkspaceHub.switchToWorkspace(desk.wsId)
                                }
                            }
                        }
                    }
                }

                // --- Layer 2: flat window chips (overview windowSpace) ---
                // All chips share this parent so they can drag across tiles without reparent.
                Item {
                    id: windowSpace
                    anchors.fill: parent
                    z: 10

                    // Rebuild when hub data changes
                    property var allClients: {
                        const m = WorkspaceHub.clientsByWorkspace
                        const out = []
                        if (!m)
                            return out
                        for (let w = 1; w <= root.wsCount; w++) {
                            const list = m[String(w)]
                            if (!list)
                                continue
                            for (let i = 0; i < list.length; i++)
                                out.push(list[i])
                        }
                        return out
                    }

                    Repeater {
                        model: windowSpace.allClients

                        Item {
                            id: winChip
                            // modelData is a plain client object from the hub
                            property string address: modelData.address || ""
                            property int homeWorkspace: modelData.workspaceId || 1
                            property string className: modelData.className || ""
                            property string title: modelData.title || ""
                            property string iconSource: modelData.icon || ""
                            property bool dragInProgress: false
                            property real homeX: 0
                            property real homeY: 0

                            // Scaled position inside mini-desktop
                            readonly property real pad: Tokens.workspaceMiniPad
                            readonly property real innerW: Math.max(1, gridHost.miniWidth() - 2 * pad)
                            readonly property real innerH: Math.max(1, gridHost.miniHeight() - 2 * pad)

                            readonly property real nx: Math.max(0, Math.min(0.88,
                                (modelData.x || 0) / root.screenW))
                            readonly property real ny: Math.max(0, Math.min(0.88,
                                (modelData.y || 0) / root.screenH))
                            readonly property real nw: Math.max(0.16, Math.min(
                                1 - nx, (modelData.w || 200) / root.screenW))
                            readonly property real nh: Math.max(0.16, Math.min(
                                1 - ny, (modelData.h || 200) / root.screenH))

                            // Absolute position on flat windowSpace
                            x: gridHost.miniX(homeWorkspace) + pad + nx * innerW
                            y: gridHost.miniY(homeWorkspace) + pad + ny * innerH
                            width:  Math.max(root.iconSz + 8, nw * innerW)
                            height: Math.max(root.iconSz + 8, nh * innerH)
                            z: dragInProgress ? 99999 : 1

                            // Hide chip when mid-drag and model refreshes would clobber —
                            // only hide OTHER chips? Keep self visible.
                            // When address matches active drag and we're a stale clone, hide.
                            visible: !(root.isDragging
                                && root.draggingAddress === address
                                && !dragInProgress)

                            // Overview: Drag.active is set in onPressed/onReleased (not bound)
                            Drag.source: winChip
                            Drag.hotSpot.x: width / 2
                            Drag.hotSpot.y: height / 2
                            Drag.supportedActions: Qt.MoveAction

                            Rectangle {
                                anchors.fill: parent
                                radius: Tokens.radiusSm
                                color: dragArea.containsMouse || winChip.dragInProgress
                                    ? Theme.bgElevated : Theme.bgSurface
                                border.color: winChip.dragInProgress
                                    ? Theme.accent
                                    : (dragArea.containsMouse
                                       ? Theme.borderActive : Theme.borderIdle)
                                border.width: Tokens.strokeWidth
                            }

                            Image {
                                id: chipIcon
                                anchors.centerIn: parent
                                width:  Math.min(root.iconSz, parent.width - 6)
                                height: Math.min(root.iconSz, parent.height - 6)
                                source: winChip.iconSource
                                sourceSize: Qt.size(Math.max(1, width * 2), Math.max(1, height * 2))
                                fillMode: Image.PreserveAspectFit
                                asynchronous: true
                                smooth: true
                                visible: status === Image.Ready
                            }

                            Text {
                                anchors.centerIn: parent
                                visible: chipIcon.status !== Image.Ready
                                text: {
                                    const t = winChip.className || winChip.title || "?"
                                    return String(t).charAt(0).toUpperCase()
                                }
                                font.family: Theme.fontDisplay
                                font.pixelSize: Tokens.fontSizeSmall
                                color: Theme.accent
                            }

                            MouseArea {
                                id: dragArea
                                anchors.fill: parent
                                hoverEnabled: true
                                preventStealing: true
                                cursorShape: drag.active
                                    ? Qt.ClosedHandCursor : Qt.OpenHandCursor
                                acceptedButtons: Qt.LeftButton
                                drag.target: winChip
                                drag.axis: Drag.XAndYAxis
                                drag.smoothed: false
                                drag.threshold: 4

                                property bool moved: false

                                onPressed: (mouse) => {
                                    moved = false
                                    winChip.homeX = winChip.x
                                    winChip.homeY = winChip.y
                                    winChip.dragInProgress = true
                                    root.draggingFromWorkspace = winChip.homeWorkspace
                                    root.draggingTargetWorkspace = winChip.homeWorkspace
                                    root.draggingAddress = winChip.address
                                    WorkspaceHub.dragActive = true

                                    // Overview pattern: set Drag + hotspot on press
                                    winChip.Drag.source = winChip
                                    winChip.Drag.hotSpot.x = mouse.x
                                    winChip.Drag.hotSpot.y = mouse.y
                                    winChip.Drag.active = true
                                }

                                onPositionChanged: {
                                    if (drag.active)
                                        moved = true
                                }

                                onReleased: {
                                    const target = root.draggingTargetWorkspace
                                    const addr = root.draggingAddress
                                    const from = root.draggingFromWorkspace
                                    const wasMoved = moved

                                    winChip.Drag.active = false
                                    winChip.dragInProgress = false
                                    WorkspaceHub.dragActive = false
                                    root.draggingAddress = ""
                                    root.draggingFromWorkspace = -1
                                    root.draggingTargetWorkspace = -1

                                    if (wasMoved && addr.length && target > 0 && target !== from) {
                                        // Overview: apply move on release using tracked target
                                        WorkspaceHub.moveToWorkspace(addr, target, true)
                                    } else if (!wasMoved && addr.length) {
                                        // Snap back + focus
                                        winChip.x = winChip.homeX
                                        winChip.y = winChip.homeY
                                        WorkspaceHub.focusWindow(addr)
                                    } else {
                                        // Cancelled drop — snap back; refresh restores layout
                                        winChip.x = winChip.homeX
                                        winChip.y = winChip.homeY
                                    }

                                    Qt.callLater(function () {
                                        WorkspaceHub.refresh()
                                    })
                                }

                                onCanceled: {
                                    winChip.Drag.active = false
                                    winChip.dragInProgress = false
                                    WorkspaceHub.dragActive = false
                                    root.draggingAddress = ""
                                    root.draggingFromWorkspace = -1
                                    root.draggingTargetWorkspace = -1
                                    winChip.x = winChip.homeX
                                    winChip.y = winChip.homeY
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Keys.onPressed: (event) => {
        if (event.key === Qt.Key_Escape) {
            Globals.closeWorkspaceBoard()
            event.accepted = true
        }
    }
    focus: true

    Component.onCompleted: WorkspaceHub.refresh()
    Connections {
        target: Globals
        function onWorkspaceBoardOpenChanged() {
            if (Globals.workspaceBoardOpen) {
                root.draggingAddress = ""
                root.draggingTargetWorkspace = -1
                root.draggingFromWorkspace = -1
                WorkspaceHub.dragActive = false
                WorkspaceHub.refresh()
                root.forceActiveFocus()
            }
        }
    }
}
