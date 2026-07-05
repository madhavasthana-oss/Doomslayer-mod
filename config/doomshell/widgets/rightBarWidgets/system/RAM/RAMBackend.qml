import Quickshell
import Quickshell.Io
import QtQuick
import "../../../.."
Item {
    id: ramBackend

    property int     __num_proc__ : 10
    property double __ram_in_use__: -1.00
    property double __ram_total__ : -1.00

    ListModel {
        id: procData
    }

    property alias processes: procData
    property bool __is_ready__: false

    // Tracks pids we've frozen with SIGSTOP so the UI can toggle Halt/Resume correctly.
    property var __halted_pids__: ({})

    function isHalted(pid) {
        return __halted_pids__[pid] === true
    }

    function killProcess(pid) {
        if (!pid || pid <= 0) return
        delete __halted_pids__[pid]
        __halted_pids__ = __halted_pids__
        killProc.pidArg = String(pid)
        killProc.running = true
    }

    function toggleHaltProcess(pid) {
        if (!pid || pid <= 0) return
        if (isHalted(pid)) {
            resumeProc.pidArg = String(pid)
            resumeProc.running = true
            delete __halted_pids__[pid]
            __halted_pids__ = __halted_pids__
        } else {
            haltProc.pidArg = String(pid)
            haltProc.running = true
            __halted_pids__[pid] = true
            __halted_pids__ = __halted_pids__
        }
    }

    // "Optimize": lower CPU + IO scheduling priority so the process competes less
    // for resources. This is the honest real-world lever available here — there is
    // no generic external call that shrinks a process's memory footprint on demand.
    function optimizeProcess(pid) {
        if (!pid || pid <= 0) return
        reniceProc.pidArg = String(pid)
        reniceProc.running = true
        ioniceProc.pidArg = String(pid)
        ioniceProc.running = true
    }

    // ---------------------------------------------------------
    //  RAM MANAGEMENT TUI LAUNCHER
    // ---------------------------------------------------------
    // Set this to whatever RAM-management TUI you use, e.g. "btop" or a
    // custom script. Left blank -> button stays disabled.
    property string __ram_tui_command__: "btm"
    property bool   __ram_tui_available__: false

    function checkRamTuiAvailable() {
        if (__ram_tui_command__.trim() === "") {
            __ram_tui_available__ = false
            return
        }
        // Only check the first token (the actual binary), not any args.
        tuiCheckProc.binArg = __ram_tui_command__.trim().split(/\s+/)[0]
        tuiCheckProc.running = true
    }

    function launchRamTui() {
        if (!__ram_tui_available__ || __ram_tui_command__.trim() === "") return
        ramTuiProc.running = true
    }

    Timer {
        id: ramTimer
        interval: 1000
        running: true
        repeat: true
        onTriggered: ramProc.running = true
    }

    Timer {
        id: topProcTimer
        interval: 2000
        running: true
        repeat: true
        onTriggered: {
            console.log("timer fired, proc count:", procData.count)
            topProcProc.running = true
        }
    }

    Process {
        id: ramProc
        command: [
            "cat",
            "/proc/meminfo"
        ]
        stdout: StdioCollector {
            onStreamFinished: {
                let data = text.trim().split("\n")
                let memTotalInfo = data.find(
                    line => line.startsWith("MemTotal")
                ).trim().match(/^MemTotal:\s*([\d]+)\s*kB/i)
                let memTotal = parseInt(memTotalInfo[1])
                __ram_total__ = parseFloat(memTotal / 1024**2).toFixed(2)
                if (!ramBackend.__is_ready__) {
                    ramBackend.__is_ready__ = true
                }
                let memAvailableInfo = data.find(
                    line => line.startsWith("MemAvailable")
                ).trim().match(/^MemAvailable:\s*([\d]+)\s*kB/i)
                let memAvailable = parseInt(memAvailableInfo[1])
                let memUsed = memTotal - memAvailable
                __ram_in_use__ = parseFloat(memUsed / 1024**2).toFixed(2)
            }
        }
    }

    Process {
        id: topProcProc
        command: [
            "ps",
            "--no-headers",
            "-axo",
            "pid,comm,rss,etimes,%cpu,%mem,nlwp,stat,pri,user,start,time,tty,state,cmd",
            "--sort=-rss"
        ]
        stdout: StdioCollector {
            onStreamFinished: {
                let lines = text.trim().split("\n").slice(0, __num_proc__)
                for (let idx = 0; idx < __num_proc__; idx++) {
                console.log("stream finished, lines:", text.trim().split("\n").length)
                    let fields = lines[idx].trim().split(/\s+/)
                    let pid    = parseInt(fields[0])
                    let name   = fields[1]
                    let rssKb  = parseInt(fields[2])
                    let upSecs = parseInt(fields[3])
                    let cpu = parseInt(fields[4])
                    let mem = parseInt(fields[5])
                    let threads = parseInt(fields[6])
                    let state = fields[7]
                    let priority = parseInt(fields[8])
                    let user = fields[9]
                    let startTime = fields[10]
                    let cpuTime = fields[11]
                    let tty = fields[12]
                    let stateDesc = fields[13]
                    let cmd = fields[14]

                    let entry = {
                        idx:    idx,
                        pid:    pid,
                        name:   name,
                        ram_mb: parseFloat(rssKb / 1024).toFixed(2),
                        uptime: formatUptime(upSecs),
                        cpu:    cpu,
                        mem:    mem,
                        threads: threads,
                        state:  state,
                        priority: priority,
                        user:   user,
                        startTime: startTime,
                        cpuTime: cpuTime,
                        tty:    tty,
                        stateDesc: stateDesc,
                        cmd:    cmd
                    }

                    if (idx < procData.count) {
                        procData.set(idx, entry)
                    } else {
                        procData.append(entry)
                    }
                }
            }
        }
    }

    Process {
        id: killProc
        property string pidArg: ""
        command: ["kill", "-TERM", pidArg]
        stdout: StdioCollector {
            onStreamFinished: topProcProc.running = true
        }
    }

    Process {
        id: haltProc
        property string pidArg: ""
        command: ["kill", "-STOP", pidArg]
    }

    Process {
        id: resumeProc
        property string pidArg: ""
        command: ["kill", "-CONT", pidArg]
    }

    Process {
        id: reniceProc
        property string pidArg: ""
        // Lower CPU scheduling priority (higher niceness = less CPU priority).
        command: ["renice", "-n", "10", "-p", pidArg]
    }

    Process {
        id: ioniceProc
        property string pidArg: ""
        // Best-effort IO class, lowest priority level within it.
        command: ["ionice", "-c", "2", "-n", "7", "-p", pidArg]
    }

    Process {
        id: tuiCheckProc
        property string binArg: ""
        command: ["which", binArg]
        onExited: (exitCode, exitStatus) => {
            ramBackend.__ram_tui_available__ = (exitCode === 0)
        }
    }

    Process {
        id: ramTuiProc
        command: ["ghostty", "-e", "sh", "-c", __ram_tui_command__]
    }

    Component.onCompleted: checkRamTuiAvailable()

    function formatUptime(totalSeconds) {
        let hours   = Math.floor(totalSeconds / 3600)
        let minutes = Math.floor((totalSeconds % 3600) / 60)
        if (hours > 0) {
            return hours + "h " + minutes + "m"
        }
        return minutes + "m"
    }
}