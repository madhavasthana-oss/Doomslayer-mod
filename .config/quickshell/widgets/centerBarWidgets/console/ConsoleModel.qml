/*
   █████████                                       ████           ██████   ██████              █████          ████ 
  ███▒▒▒▒▒███                                     ▒▒███          ▒▒██████ ██████              ▒▒███          ▒▒███ 
 ███     ▒▒▒   ██████  ████████    █████   ██████  ▒███   ██████  ▒███▒█████▒███   ██████   ███████   ██████  ▒███ 
▒███          ███▒▒███▒▒███▒▒███  ███▒▒   ███▒▒███ ▒███  ███▒▒███ ▒███▒▒███ ▒███  ███▒▒███ ███▒▒███  ███▒▒███ ▒███ 
▒███         ▒███ ▒███ ▒███ ▒███ ▒▒█████ ▒███ ▒███ ▒███ ▒███████  ▒███ ▒▒▒  ▒███ ▒███ ▒███▒███ ▒███ ▒███████  ▒███ 
▒▒███     ███▒███ ▒███ ▒███ ▒███  ▒▒▒▒███▒███ ▒███ ▒███ ▒███▒▒▒   ▒███      ▒███ ▒███ ▒███▒███ ▒███ ▒███▒▒▒   ▒███ 
 ▒▒█████████ ▒▒██████  ████ █████ ██████ ▒▒██████  █████▒▒██████  █████     █████▒▒██████ ▒▒████████▒▒██████  █████
  ▒▒▒▒▒▒▒▒▒   ▒▒▒▒▒▒  ▒▒▒▒ ▒▒▒▒▒ ▒▒▒▒▒▒   ▒▒▒▒▒▒  ▒▒▒▒▒  ▒▒▒▒▒▒  ▒▒▒▒▒     ▒▒▒▒▒  ▒▒▒▒▒▒   ▒▒▒▒▒▒▒▒  ▒▒▒▒▒▒  ▒▒▒▒▒ 
  
 This file will handle the data of Console entries, and further information has been given as follows

 Each codex entry will have the following data

 1. Title --- The name of the application
 2. Classification --- The objective of the application in question
 3. Description --- the description of each application, the doom analog of course
 4. Icon --- self explanatory
 5. ExecCmd --- called in the ListView when clicked on the delegate to launch the application, this is necessary to preserve modularity

    It goes without saying that the entries will be indexed beginning from 0.

 Currently, the following applications will be added

 1. Default terminal (for me it is <GhosTTY>, you can freely change the description of each entry here. The ListModel will parse every thing in a for loop, so all entries added will be covered)
 2. Default Browser (Firefox)
 3. Default file manager
 4. Default music player (TUI, or app, both are supported)
 5. Default Editor (<Neovim> for me, yeah I know, I'm still learning NeoVim too)
 6. Default Agent (<Grok Build> for me, once again, feel free to mutate the entries to your liking, and also share your additions)
  */
import QtQuick
import Quickshell
import QtQml.Models
import Quickshell.Io
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Services


QtObject {
    id: root

    // Expose the model to Console.qml
    property alias codexModel: codexData

    ListModel {
        id: codexData

        ListElement {
            title: "Ghostty"
            classification: "Command Line Control Center"

            description: "The gateway to the heart of the machine. Every process bends to the Slayer's will. Every command carves another scar into the system. The machine obeys without hesitation."

            icon: "/usr/share/icons/Papirus/64x64/apps/com.mitchellh.ghostty.svg"

            execCmd: "ghostty"
        }

        ListElement {
            title: "Firefox"
            classification: "Reconnaissance Interface"

            description: "Survey enemy territory. Gather intelligence from the wastelands of the internet. Return with knowledge before the corruption spreads."

            icon: "~/.local/share/icons/besgnulinux-mono-red/categories/scalable/firefox.svg"

            execCmd: "firefox"
        }

        ListElement {
            title: "Dolphin"
            classification: "Filesystem Navigator"

            description: "Traverse the machine's archives. Recover forgotten relics. Purge corrupted sectors and restore order to the filesystem."

            icon: "~/.local/share/icons/besgnulinux-mono-red/apps/scalable/dolphin.svg"

            execCmd: "dolphin"
        }

        ListElement {
            title: "Music"
            classification: "Combat Audio System"

            description: "Every Slayer marches to a soundtrack. Arm the battlefield with music worthy of the coming war."

            icon: "multimedia-player"

            execCmd: "spotify"
            // Replace with your preferred player.
        }

        ListElement {
            title: "Neovim"
            classification: "Weapon Development Interface"

            description: "Forged from Neovim and tempered by the Slayer. The remnants of an ancient virus still stain its crimson shell, but the corruption has long since been purged. Only steel, code, and purpose remain."

            icon: "~/.local/share/icons/besgnulinux-mono-red/apps/scalable/io.neovim.nvim.svg"

            execCmd: "ghostty -e nvim"
        }

        ListElement {
            title: "VEGA"
            classification: "Sentinel Artificial Intelligence"

            description: "Mission analysis. Strategic planning. System diagnostics. Awaiting authorization to interface with the Slayer."

            icon: "~/.local/share/icons/besgnulinux-mono-red/apps/scalable/doom.svg"

            execCmd: "grok"
            // Replace with the command that launches your Grok build.
        }
    }
}