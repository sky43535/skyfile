#!/bin/bash

set -e

REPO="sky43535/skyfile"
BINARY="skyfile"
URL="https://github.com/$REPO/releases/latest/download/$BINARY"

# ─────────────────────────────
# Colors
# ─────────────────────────────

RESET="\033[0m"
GREEN="\033[1;32m"
BLUE="\033[1;34m"
CYAN="\033[1;36m"
YELLOW="\033[1;33m"
RED="\033[1;31m"

clear

echo -e "${CYAN}"
echo "███████╗██╗  ██╗██╗   ██╗███████╗██╗██╗     ███████╗"
echo "██╔════╝██║ ██╔╝╚██╗ ██╔╝██╔════╝██║██║     ██╔════╝"
echo "███████╗█████╔╝  ╚████╔╝ █████╗  ██║██║     █████╗  "
echo "╚════██║██╔═██╗   ╚██╔╝  ██╔══╝  ██║██║     ██╔══╝  "
echo "███████║██║  ██╗   ██║   ██║     ██║███████╗███████╗"
echo "╚══════╝╚═╝  ╚═╝   ╚═╝   ╚═╝     ╚═╝╚══════╝╚══════╝"
echo "                                                   "
echo -e "${RESET}"

echo -e "${BLUE}Welcome to SkyFile Installer${RESET}"
echo -e "${CYAN}──────────────────────────────────────${RESET}"
echo ""

# Detect OS
OS="$(uname -s)"

echo -e "${YELLOW}🔍 Detecting system...${RESET}"

case "$OS" in
  Darwin)
    echo -e "${GREEN}✔ macOS detected${RESET}"
    ;;
  Linux)
    echo -e "${GREEN}✔ Linux detected${RESET}"
    ;;
  *)
    echo -e "${RED}✖ Unsupported system: $OS${RESET}"
    exit 1
    ;;
esac

echo ""
echo -e "${YELLOW}⬇ Downloading latest SkyFile...${RESET}"

# ─────────────────────────────
# SAFE DOWNLOAD (fixes your crash)
# ─────────────────────────────

TMP_FILE="$(mktemp)"

curl -L --fail --progress-bar "$URL" -o "$TMP_FILE"

echo ""
echo -e "${YELLOW}🔧 Setting permissions...${RESET}"
chmod +x "$TMP_FILE"

echo -e "${YELLOW}📦 Installing to system...${RESET}"

DEST="/usr/local/bin/skyfile"

if [ -w "$(dirname "$DEST")" ]; then
    mv "$TMP_FILE" "$DEST"
else
    sudo mv "$TMP_FILE" "$DEST"
fi

echo ""
echo -e "${CYAN}──────────────────────────────────────${RESET}"
echo -e "${GREEN}✨ SkyFile installed successfully!${RESET}"
echo -e "${BLUE}👉 Run: skyfile --help${RESET}"
echo -e "${CYAN}──────────────────────────────────────${RESET}"
echo ""
