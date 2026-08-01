// WorkspaceBoard.qml --- mini-desktop grid + manual drag between workspaces
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
    readonly property real screenAspect: screenW / screenH
    readonly property int iconSz: Tokens.workspaceBoardIcon
    readonly property int gap: Tokens.spacingSm

    // Manual drag state (more reliable than QML Drag across Flickable/clip)
    property bool dragging: false
    property string dragAddress: ""
    property string dragIcon: ""
    property string dragTitle: ""
    property string dragClass: ""
    property int dragFromWs: 0
    property real dragX: 0
    property real dragY: 0

    // Coordinates are always relative to this board root (not global)
    function beginDrag(address, icon, title, className, fromWs, localX, localY) {
        dragging = true
        dragAddress = address
        dragIcon = icon || ""
        dragTitle = title || ""
        dragClass = className || ""
        dragFromWs = fromWs
        dragX = localX - iconSz / 2
        dragY = localY - iconSz / 2
        WorkspaceHub.dragActive = true
    }

    function updateDrag(localX, localY) {
        if (!dragging)
            return
        dragX = localX - iconSz / 2
        dragY = localY - iconSz / 2
    }

    function endDrag(localX, localY) {
        if (!dragging)
            return
        let targetWs = -1

        // Hit-test mini desktop frames
        for (let i = 0; i < deskRepeater.count; i++) {
            const item = deskRepeater.itemAt(i)
            if (!item)
                continue
            const local = item.mapFromItem(root, localX, localY)
            if (local.x >= 0 && local.y >= 0
                    && local.x <= item.width && local.y <= item.height) {
                targetWs = item.wsId
                break
            }
        }

        if (targetWs > 0 && targetWs !== dragFromWs && dragAddress.length)
            WorkspaceHub.moveToWorkspace(dragAddress, targetWs, true)

        dragging = false
        dragAddress = ""
        dragFromWs = 0
        WorkspaceHub.dragActive = false
        WorkspaceHub.refresh()
    }

    function cancelDrag() {
        dragging = false
        dragAddress = ""
        dragFromWs = 0
        WorkspaceHub.dragActive = false
    }

    // Absorb clicks so dim overlay doesn't close when clicking the card
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
                text: dragging
                    ? ("dragging → drop on a desktop")
                    : ("drag windows between mini-desktops · " + root.wsCount + " workspaces")
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

        // Grid of mini-desktops
        Item {
            id: gridHost
            Layout.fillWidth: true
            Layout.fillHeight: true

            // Compute cell size to fit cols×rows with landscape aspect
            readonly property int hGap: root.gap
            readonly property int vGap: root.gap
            readonly property int cellW: Math.floor(
                (width - hGap * (root.cols - 1)) / root.cols)
            // Header + footer + landscape screen
            readonly property int headerH: Tokens.listRowHeight
            readonly property int footerH: Tokens.listRowHeight
            readonly property int screenH: Math.floor(cellW / root.screenAspect)
            readonly property int cellH: headerH + screenH + footerH + Tokens.spacingXss * 2

            // Center the grid block
            readonly property int gridW: cellW * root.cols + hGap * (root.cols - 1)
            readonly property int gridH: cellH * root.rows + vGap * (root.rows - 1)

            Item {
                id: grid
                width:  gridHost.gridW
                height: gridHost.gridH
                anchors.centerIn: parent

                Repeater {
                    id: deskRepeater
                    model: root.wsCount

                    Item {
                        id: desk
                        property int wsId: index + 1
                        property bool isFocused: WorkspaceHub.focusedWorkspaceId === wsId
                        property bool dropHover: false
                        property var clients: WorkspaceHub.clientsOn(wsId)

                        width:  gridHost.cellW
                        height: gridHost.cellH
                        x: (index % root.cols) * (gridHost.cellW + gridHost.hGap)
                        y: Math.floor(index / root.cols) * (gridHost.cellH + gridHost.vGap)

                        // Highlight when drag ghost is over this desk
                        property bool dragOver: {
                            if (!root.dragging)
                                return false
                            const p = desk.mapFromItem(root,
                                root.dragX + root.iconSz / 2,
                                root.dragY + root.iconSz / 2)
                            return p.x >= 0 && p.y >= 0 && p.x <= width && p.y <= height
                        }

                        ColumnLayout {
                            anchors.fill: parent
                            spacing: Tokens.spacingXss

                            // Title bar of mini screen
                            RowLayout {
                                Layout.fillWidth: true
                                Layout.preferredHeight: gridHost.headerH
                                spacing: Tokens.spacingXs

                                Text {
                                    text: "WS " + desk.wsId
                                    font.family: Theme.fontDisplay
                                    font.pixelSize: Tokens.fontSizeLabel
                                    color: desk.isFocused ? Theme.accent : Theme.textDim
                                }
                                Item { Layout.fillWidth: true }
                                Text {
                                    text: String(desk.clients.length)
                                    font.family: Theme.fontMono
                                    font.pixelSize: Tokens.fontSizeTiny
                                    color: Theme.textMuted
                                }
                            }

                            // === Mini desktop bezel (landscape screen) ===
                            Rectangle {
                                id: bezel
                                Layout.fillWidth: true
                                Layout.preferredHeight: gridHost.screenH
                                Layout.maximumHeight: gridHost.screenH
                                radius: Tokens.radiusMd
                                color: Theme.bgPrimary
                                border.color: desk.dragOver ? Theme.accent
                                            : (desk.isFocused ? Theme.borderActive : Theme.borderIdle)
                                border.width: desk.dragOver ? Math.max(2, Tokens.strokeWidthActive)
                                            : Tokens.strokeWidth
                                clip: true

                                // Inner screen surface
                                Rectangle {
                                    id: screen
                                    anchors.fill: parent
                                    anchors.margins: Tokens.workspaceMiniPad
                                    radius: Tokens.radiusSm
                                    color: Theme.bgConsole
                                    border.color: Theme.borderIdle
                                    border.width: Tokens.strokeWidth
                                    clip: true

                                    // Windows as scaled rectangles in layout positions
                                    Repeater {
                                        model: desk.clients

                                        Item {
                                            id: winChip
                                            // Relative position on real monitor → mini screen
                                            property real nx: Math.max(0, Math.min(0.92, modelData.x / root.screenW))
                                            property real ny: Math.max(0, Math.min(0.92, modelData.y / root.screenH))
                                            property real nw: Math.max(0.12, Math.min(1 - nx, modelData.w / root.screenW))
                                            property real nh: Math.max(0.12, Math.min(1 - ny, modelData.h / root.screenH))

                                            x: nx * screen.width
                                            y: ny * screen.height
                                            width:  Math.max(root.iconSz + 4, nw * screen.width)
                                            height: Math.max(root.iconSz + 4, nh * screen.height)

                                            visible: !(root.dragging && root.dragAddress === modelData.address)

                                            Rectangle {
                                                anchors.fill: parent
                                                radius: Tokens.radiusSm
                                                color: chipMouse.containsMouse ? Theme.bgElevated : Theme.bgSurface
                                                border.color: chipMouse.containsMouse
                                                    ? Theme.borderActive : Theme.borderIdle
                                                border.width: Tokens.strokeWidth
                                            }

                                            Image {
                                                id: chipIcon
                                                anchors.centerIn: parent
                                                width:  Math.min(root.iconSz, parent.width - 6)
                                                height: Math.min(root.iconSz, parent.height - 6)
                                                source: modelData.icon || ""
                                                sourceSize: Qt.size(width * 2, height * 2)
                                                fillMode: Image.PreserveAspectFit
                                                asynchronous: true
                                                smooth: true
                                                visible: status === Image.Ready
                                            }

                                            Text {
                                                anchors.centerIn: parent
                                                visible: chipIcon.status !== Image.Ready
                                                text: {
                                                    const t = modelData.className || modelData.title || "?"
                                                    return String(t).charAt(0).toUpperCase()
                                                }
                                                font.family: Theme.fontDisplay
                                                font.pixelSize: Tokens.fontSizeSmall
                                                color: Theme.accent
                                            }

                                            MouseArea {
                                                id: chipMouse
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: pressed ? Qt.ClosedHandCursor : Qt.OpenHandCursor
                                                preventStealing: true

                                                property real pressX: 0
                                                property real pressY: 0
                                                property bool armed: false

                                                function toBoard(mx, my) {
                                                    return chipMouse.mapToItem(root, mx, my)
                                                }

                                                onPressed: (mouse) => {
                                                    armed = true
                                                    const p = toBoard(mouse.x, mouse.y)
                                                    pressX = p.x
                                                    pressY = p.y
                                                }
                                                onPositionChanged: (mouse) => {
                                                    if (!pressed || !armed)
                                                        return
                                                    const p = toBoard(mouse.x, mouse.y)
                                                    const dx = p.x - pressX
                                                    const dy = p.y - pressY
                                                    if (!root.dragging && (dx * dx + dy * dy) > 64) {
                                                        root.beginDrag(
                                                            modelData.address,
                                                            modelData.icon,
                                                            modelData.title,
                                                            modelData.className,
                                                            modelData.workspaceId,
                                                            p.x, p.y
                                                        )
                                                    } else if (root.dragging) {
                                                        root.updateDrag(p.x, p.y)
                                                    }
                                                }
                                                onReleased: (mouse) => {
                                                    const p = toBoard(mouse.x, mouse.y)
                                                    if (root.dragging) {
                                                        root.endDrag(p.x, p.y)
                                                    } else if (armed) {
                                                        WorkspaceHub.focusWindow(modelData.address)
                                                    }
                                                    armed = false
                                                }
                                                onCanceled: {
                                                    root.cancelDrag()
                                                    armed = false
                                                }
                                            }
                                        }
                                    }

                                    Text {
                                        anchors.centerIn: parent
                                        visible: desk.clients.length === 0
                                        text: "empty"
                                        font.family: Theme.fontMono
                                        font.pixelSize: Tokens.fontSizeTiny
                                        color: Theme.textDim
                                    }
                                }
                            }

                            // Focus footer
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
            }
        }
    }

    // Drag ghost (follows cursor, above everything)
    Item {
        id: ghost
        visible: root.dragging
        x: root.dragX
        y: root.dragY
        width:  root.iconSz + Tokens.spacingMd
        height: root.iconSz + Tokens.spacingMd
        z: 10000

        Rectangle {
            anchors.fill: parent
            radius: Tokens.radiusMd
            color: Theme.bgElevated
            border.color: Theme.accent
            border.width: Tokens.strokeWidthActive
            opacity: 0.95
        }

        Image {
            id: ghostIcon
            anchors.centerIn: parent
            width:  root.iconSz
            height: root.iconSz
            source: root.dragIcon
            sourceSize: Qt.size(width * 2, height * 2)
            fillMode: Image.PreserveAspectFit
            visible: status === Image.Ready
            asynchronous: true
        }

        Text {
            anchors.centerIn: parent
            visible: ghostIcon.status !== Image.Ready
            text: {
                const t = root.dragClass || root.dragTitle || "?"
                return String(t).charAt(0).toUpperCase()
            }
            font.family: Theme.fontDisplay
            font.pixelSize: Tokens.fontSizeMedium
            color: Theme.accent
        }
    }

    // Track pointer on the board while dragging (mouse left the chip)
    MouseArea {
        anchors.fill: parent
        enabled: root.dragging
        hoverEnabled: true
        preventStealing: true
        z: 9999
        cursorShape: Qt.ClosedHandCursor
        onPositionChanged: (mouse) => root.updateDrag(mouse.x, mouse.y)
        onReleased: (mouse) => root.endDrag(mouse.x, mouse.y)
        onCanceled: root.cancelDrag()
    }

    Keys.onPressed: (event) => {
        if (event.key === Qt.Key_Escape) {
            if (root.dragging)
                root.cancelDrag()
            else
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
                root.cancelDrag()
                WorkspaceHub.refresh()
                root.forceActiveFocus()
            }
        }
    }
}
