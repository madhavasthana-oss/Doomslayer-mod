#!/usr/bin/env bash
# ─────────────────────────────────────────
#  SLAYER COLOR PALETTE — source this file
#  Usage: source "$(dirname "$0")/colors.sh"
# ─────────────────────────────────────────

# Reset
RESET='\033[0m'

# Red family (core palette)
RED_HOT='\033[1;31m'       # Bright red   — banners, highlights
RED_MID='\033[0;31m'       # Normal red   — values, prompts
RED_DIM='\033[2;31m'       # Dim red      — separators, labels
RED_BLOOD='\033[38;5;88m'  # Deep blood   — subtle accents
RED_EMBER='\033[38;5;124m' # Ember red    — mid-depth accents
RED_ASH='\033[38;5;52m'    # Near-black red — background text

# Orange-red edge tones
ORANGE_DARK='\033[38;5;130m'  # Dark orange — warm accent
ORANGE_DIM='\033[38;5;94m'    # Muted ochre — deep warm tone

# Text modifiers
BOLD='\033[1m'
DIM='\033[2m'
ITALIC='\033[3m'
UNDERLINE='\033[4m'

# Utility
SEP="${RED_ASH}───────────────────────────────────────────────────────${RESET}"
ARROW="${RED_DIM}▸${RESET}"
PROMPT_CHAR="${RED_HOT}❯${RESET}"