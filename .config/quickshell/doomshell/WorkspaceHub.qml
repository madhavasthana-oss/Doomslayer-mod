// WorkspaceHub.qml --- live hyprctl client list + move/focus helpers
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

Singleton {
    id: root

    // All mapped clients (sorted by workspace, then layout x/y)
    ListModel { id: clientModel }
    property alias clients: clientModel

    // Clients on the focused workspace only (array of plain objects)
    property var focusedClients: []
    // Map workspaceId (string key) → array of client objects (for bar badges)
    property var clientsByWorkspace: ({})

    property int focusedWorkspaceId: Hyprland.focusedWorkspace?.id ?? 1
    property int screenW: Tokens.screenWidth > 0 ? Tokens.screenWidth : 1920
    property int screenH: Tokens.screenHeight > 0 ? Tokens.screenHeight : 1080
    property bool refreshing: false
    // Set while a board chip is mid-drag so poll won't rebuild the model
    property bool dragActive: false

    // Always expose at least workspaceNumber columns (1..N)
    property int maxWorkspace: Globals.workspaceNumber

    function clientsOn(wsId) {
        const key = String(wsId)
        const m = root.clientsByWorkspace
        if (m && m[key])
            return m[key]
        return []
    }

    function normalizeAddress(addr) {
        let a = String(addr || "").trim()
        if (!a.length)
            return ""
        if (a.indexOf("address:") === 0)
            a = a.substring("address:".length)
        return a
    }

    function addressSelector(addr) {
        const a = normalizeAddress(addr)
        return a.length ? ("address:" + a) : ""
    }

    function iconForClass(cls) {
        if (!cls || !String(cls).length)
            return ""
        const c = String(cls)
        let p = Quickshell.iconPath(c, true)
        if (p && p.length)
            return p
        // reverse-domain → last segment (com.mitchellh.ghostty → ghostty)
        const parts = c.split(".")
        if (parts.length > 1) {
            p = Quickshell.iconPath(parts[parts.length - 1], true)
            if (p && p.length)
                return p
            p = Quickshell.iconPath(parts[parts.length - 1].toLowerCase(), true)
            if (p && p.length)
                return p
        }
        p = Quickshell.iconPath(c.toLowerCase(), true)
        return (p && p.length) ? p : ""
    }

    function refresh() {
        if (refreshing || dragActive)
            return
        refreshing = true
        clientsProc.running = true
    }

    function parseClients(text) {
        clientModel.clear()
        let focused = []
        const byWs = ({})
        // Cap display at configured count (still track higher for groups if needed)
        const maxWs = Globals.workspaceNumber

        try {
            const arr = JSON.parse(text.length ? text : "[]")
            if (!Array.isArray(arr)) {
                root.focusedClients = []
                root.clientsByWorkspace = ({})
                root.refreshing = false
                return
            }

            const rows = []
            for (let i = 0; i < arr.length; i++) {
                const c = arr[i]
                if (!c || c.mapped === false || c.hidden === true)
                    continue
                const wsId = c.workspace && c.workspace.id !== undefined
                    ? parseInt(c.workspace.id) : 0
                // Only regular workspaces in the configured range for board/bar
                if (isNaN(wsId) || wsId <= 0 || wsId > maxWs)
                    continue

                const at = c.at || [0, 0]
                const sz = c.size || [0, 0]
                const cls = c.class || c.initialClass || ""
                rows.push({
                    address: normalizeAddress(c.address),
                    className: cls,
                    title: c.title || cls || "Window",
                    workspaceId: wsId,
                    x: at[0] || 0,
                    y: at[1] || 0,
                    w: sz[0] || 0,
                    h: sz[1] || 0,
                    floating: !!c.floating,
                    icon: iconForClass(cls)
                })
            }

            // Layout order: workspace → x → y
            rows.sort(function (a, b) {
                if (a.workspaceId !== b.workspaceId)
                    return a.workspaceId - b.workspaceId
                if (a.x !== b.x)
                    return a.x - b.x
                return a.y - b.y
            })

            const fw = root.focusedWorkspaceId
            for (let j = 0; j < rows.length; j++) {
                const r = rows[j]
                clientModel.append(r)
                const key = String(r.workspaceId)
                if (!byWs[key])
                    byWs[key] = []
                byWs[key].push(r)
                if (r.workspaceId === fw)
                    focused.push(r)
            }

            root.maxWorkspace = maxWs
            root.focusedClients = focused
            root.clientsByWorkspace = byWs
        } catch (e) {
            root.focusedClients = []
            root.clientsByWorkspace = ({})
            console.warn("WorkspaceHub: parse failed", e)
        }
        root.refreshing = false
    }

    function focusWindow(address) {
        const sel = addressSelector(address)
        if (!sel.length)
            return
        if (Hyprland.usingLua)
            Hyprland.dispatch("hl.dsp.focus({ window = \"" + sel + "\" })")
        else
            Hyprland.dispatch("focuswindow " + sel)
        root.refresh()
    }

    function moveToWorkspace(address, wsId, silent) {
        const sel = addressSelector(address)
        const ws = parseInt(wsId)
        if (!sel.length || isNaN(ws) || ws <= 0)
            return

        const sil = silent !== false  // default silent
        if (Hyprland.usingLua) {
            let args = "workspace = " + ws + ", window = \"" + sel + "\""
            if (sil)
                args += ", silent = true"
            Hyprland.dispatch("hl.dsp.window.move({ " + args + " })")
        } else {
            const cmd = sil ? "movetoworkspacesilent" : "movetoworkspace"
            Hyprland.dispatch(cmd + " " + ws + "," + sel)
        }
        // Refresh after compositor settles
        Qt.callLater(function () { root.refresh() })
        refreshSoon.restart()
    }

    function switchToWorkspace(id) {
        if (Hyprland.usingLua)
            Hyprland.dispatch("hl.dsp.focus({ workspace = " + id + " })")
        else
            Hyprland.dispatch("workspace " + id)
    }

    Process {
        id: clientsProc
        command: ["hyprctl", "-j", "clients"]
        stdout: StdioCollector {
            onStreamFinished: root.parseClients(text)
        }
        onExited: function () {
            root.refreshing = false
        }
    }

    Timer {
        id: pollTimer
        interval: Tokens.workspacePollMs
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }

    Timer {
        id: refreshSoon
        interval: 200
        repeat: false
        onTriggered: root.refresh()
    }

    Connections {
        target: Hyprland
        function onFocusedWorkspaceChanged() {
            root.focusedWorkspaceId = Hyprland.focusedWorkspace?.id ?? 1
            root.refresh()
        }
        function onActiveToplevelChanged() {
            refreshSoon.restart()
        }
    }

    Component.onCompleted: root.refresh()
}
