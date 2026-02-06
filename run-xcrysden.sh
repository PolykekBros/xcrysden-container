#!/usr/bin/env sh

IMAGE_NAME="xcrysden"
REPO_URL="https://github.com/PolykekBros/xcrysden-container.git"

# 1. Check if image exists; build if string is empty
if [ -z "$(podman images -q "$IMAGE_NAME" 2>/dev/null)" ]; then
    echo "--- Image not found. Building XCrySDen container... ---"
    podman build -t "$IMAGE_NAME" "$REPO_URL"
else
    echo "--- Image exists. Skipping build... ---"
fi

# 2. X11 permissions for local user
if command -v xhost >/dev/null 2>&1; then
    xhost +SI:localuser:"$(whoami)" >/dev/null 2>&1
fi

# 3. Execution
# Using "$@" to pass any arguments (like filenames) to the container
echo "--- Launching XCrySDen ---"
podman run --rm -it \
    --net=host \
    -e DISPLAY="$DISPLAY" \
    -v /tmp/.X11-unix:/tmp/.X11-unix:ro \
    -v "$HOME":"$HOME" \
    --workdir="$(pwd)" \
    --userns=keep-id \
    "$IMAGE_NAME" "$@"
