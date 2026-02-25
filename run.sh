#!/usr/bin/env bash
set -e

# --- Color Definitions ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# --- Helper Functions ---
info() { echo -e "${CYAN}ℹ️  $1${NC}"; }
success() { echo -e "${GREEN}✅ $1${NC}"; }
warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
error() { echo -e "${RED}❌ $1${NC}"; exit 1; }

# Check if podman is installed
if ! command -v podman > /dev/null 2>&1; then
    error "podman is not installed. Please install podman to proceed."
fi

OS=$(uname -s)
IMAGE_NAME="localhost/xcrysden"
REPO_URL="https://github.com/PolykekBros/xcrysden-container.git"

echo -e "${BLUE}=======================================${NC}"
echo -e "${BLUE}        ⚛️  XCrySDen Launcher ⚛️        ${NC}"
echo -e "${BLUE}=======================================${NC}"

# 1. Check if image exists; build if missing
info "Checking for image '$IMAGE_NAME'..."
if [ -z "$(podman images -q "$IMAGE_NAME" 2>/dev/null)" ]; then
    warning "Image not found. Building XCrySDen container from local Containerfile..."
    
    # Detect architecture for Podman build (especially important on macOS M1/M2)
    ARCH=$(podman info --format '{{.Host.Arch}}')
    info "Building for architecture: $ARCH"
    
    podman build --arch="$ARCH" -t "$IMAGE_NAME" .
    success "Image built successfully!"
else
    success "Image '$IMAGE_NAME' exists. Skipping build..."
fi

# 2. Extract arguments
# Using "$@" to pass any arguments (like filenames) to the container

if [ "$OS" = "Darwin" ]; then
    info "Detected macOS environment 🍎"
    
    # Check if XQuartz is open
    if ! pgrep -x "X11.bin" > /dev/null; then
        warning "XQuartz is not running."
        info "Attempting to start XQuartz... (If not installed, run: brew install --cask xquartz)"
        open -a XQuartz || error "Failed to start XQuartz. Make sure it is installed and running."
        # Wait a bit longer for X11 to fully initialize
        for i in {1..5}; do
            sleep 1
            pgrep -x "X11.bin" > /dev/null && break
        done
    fi

    # Allow connections from localhost
    info "Configuring xhost to allow local connections..."
    if ! xhost +localhost > /dev/null 2>&1; then
        error "Failed to run 'xhost +localhost'. Ensure XQuartz is running and 'Allow connections from network clients' is checked in XQuartz Settings -> Security."
    fi

    # Check IGLX setting on macOS
    if [ "$(defaults read org.xquartz.X11 enable_iglx 2>/dev/null)" != "1" ]; then
        warning "XQuartz IGLX (Indirect GLX) is NOT enabled. XCrySDen will likely fail to open."
        info "Enabling it now: defaults write org.xquartz.X11 enable_iglx -bool true"
        defaults write org.xquartz.X11 enable_iglx -bool true
        echo -e "${RED}🛑  CRITICAL: IGLX has been enabled. You MUST RESTART XQuartz (Quit & Reopen) for this to take effect.${NC}"
        read -p "Press Enter to try launching anyway, or Ctrl+C to exit and restart XQuartz..."
    fi

    success "Launching XCrySDen..."
    podman run --rm -it \
        -e DISPLAY=host.containers.internal:0 \
        -e LIBGL_ALWAYS_SOFTWARE=1 \
        -e LIBGL_ALWAYS_INDIRECT=1 \
        -v /tmp/.X11-unix:/tmp/.X11-unix:ro \
        -v "$HOME":"$HOME" \
        -v "$(pwd)":"$(pwd)" \
        --workdir="$(pwd)" \
        "$IMAGE_NAME" "$@"

elif [ "$OS" = "Linux" ]; then
    info "Detected Linux environment 🐧"
    
    # X11 permissions for local user
    if command -v xhost >/dev/null 2>&1; then
        info "Ensuring local user has X11 permissions..."
        xhost +SI:localuser:"$(whoami)" >/dev/null 2>&1
    fi

    success "Launching XCrySDen..."
    podman run --rm -it \
        --net=host \
        -e DISPLAY="$DISPLAY" \
        -v /tmp/.X11-unix:/tmp/.X11-unix:ro \
        -v "$HOME":"$HOME" \
        -v "$(pwd)":"$(pwd)" \
        --workdir="$(pwd)" \
        --userns=keep-id \
        "$IMAGE_NAME" "$@"

else
    error "Unsupported Operating System: $OS"
fi
