/*
  Console codex entries:
  title, classification, description, icon, execCmd
*/
import QtQuick

Item {
    id: root

    property alias codexModel: codexData

    ListModel {
        id: codexData

        ListElement {
            title: "GhosTTY"
            classification: "Command Line Control Center 1"
            description: "The gateway to the heart of the machine. Every process bends to the Slayer's will. Every command carves another scar into the system. The machine obeys without hesitation."
            icon: "com.mitchellh.ghostty"
            execCmd: "ghostty"
        }
        
        ListElement {
            title: "KiTTY"
            classification: "Command Line Control Center 2"
            description: "A highly combat tested, and powerful GPU-accelerated terminal. Coded in C and python, if GhosTTY is perhaps too heavy, then KiTTY is your go to."
            icon: "kitty"
            execCmd: "kitty"
        }


        ListElement {
            title: "Firefox"
            classification: "Reconnaissance Interface"
            description: "Survey enemy territory. Gather intelligence from the wastelands of the internet. Return with knowledge before the corruption spreads."
            icon: "firefox"
            execCmd: "firefox"
        }

        ListElement {
            title: "Dolphin"
            classification: "Filesystem Navigator"
            description: "Traverse the machine's archives. Recover forgotten relics. Purge corrupted sectors and restore order to the filesystem."
            icon: "org.kde.dolphin"
            execCmd: "dolphin"
        }

        ListElement {
            title: "Music"
            classification: "Combat Audio System"
            description: "Every Slayer marches to a soundtrack. Arm the battlefield with music worthy of the coming war."
            icon: "multimedia-audio-player"
            execCmd: "youtube-music-desktop-app"
        }

        ListElement {
            title: "Neovim"
            classification: "Weapon Development Interface"
            description: "Forged from Neovim and tempered by the Slayer. The remnants of an ancient virus still stain its crimson shell, but the corruption has long since been purged. Only steel, code, and purpose remain."
            icon: "nvim"
            execCmd: "kitty -e nvim"
        }

        ListElement {
            title: "VEGA"
            classification: "Sentinel Artificial Intelligence"
            description: "Mission analysis. Strategic planning. System diagnostics. Awaiting authorization to interface with the Slayer."
            icon: "grok"
            execCmd: "kitty -e grok"
        }
    }
}
