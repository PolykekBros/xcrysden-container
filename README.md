# XCrySDen Container

A containerized version of XCrySDen. It supports running on both Linux and macOS using Podman.

## How to run (Recommended)

You can launch the container directly on both Linux and macOS using the unified run script. The script will automatically detect your operating system and apply the necessary configurations (like XQuartz and setting `xhost`).

```console
curl -sSL https://raw.githubusercontent.com/PolykekBros/xcrysden-container/main/run.sh | sh
```

Alternatively, you can clone the repository and run `./run.sh` directly. 
You can pass arguments to XCrySDen directly to open a file: `./run.sh my_structure.xsf`

---

## Running Manually

If you prefer not to use the automated `run.sh` script, you can build and run it manually. 

### Step 1. Build

This step is identical for both Linux and macOS:

```console
podman build -t xcrysden https://github.com/PolykekBros/xcrysden-container.git
```

### Step 2. Run on Linux

Before running, you may need to allow local user connections to X11 on some distributions (like Fedora):

```console
xhost +SI:localuser:$(whoami)
```

Then, run the container:

```console
podman run --rm -it \
          --net=host \
          -e DISPLAY=$DISPLAY \
          -v /tmp/.X11-unix:/tmp/.X11-unix:ro \
          -v $HOME:$HOME \
          --workdir="$(pwd)" \
          --userns=keep-id \
          xcrysden
```

### Step 2. Run on macOS

On macOS, Podman runs inside a Linux VM (Podman Machine), which means the container does not have direct access to the macOS windowing system. We need to bridge this using XQuartz and specific network configurations.

1. **Install XQuartz**
   ```console
   > brew install --cask xquartz
   ```

2. **Configure XQuartz**
   - Open XQuartz -> Settings -> Security -> Check **"Allow connections from network clients"**.
   - Enable IGLX (Indirect GLX) by running this in your terminal:
     ```console
     > defaults write org.xquartz.X11 enable_iglx -bool true
     ```
   - **Important:** YOU MUST RESTART XQUARTZ (completely quit and reopen) for these changes to take effect.


3. **Prepare the Display**
   Run the following command in the macOS terminal to allow the Podman VM to connect:
   ```console
   > xhost +localhost
   ```

4. **Run Command**
   Provide this `podman run` command tailored for Mac. It ensures the container can reach the host's X11 server and resolves OpenGL compatibility issues:

   ```bash
   podman run -it --rm \
     -e DISPLAY=host.containers.internal:0 \
     -e LIBGL_ALWAYS_SOFTWARE=1 \
     -v /tmp/.X11-unix:/tmp/.X11-unix:ro \
     -v "$HOME":"$HOME" \
     --workdir="$(pwd)" \
     xcrysden
   ```

**Why these specific instructions are needed on macOS:**
* **`host.containers.internal`**: On macOS, `localhost` inside a container points to the Podman VM, not your Mac. This special DNS name is the easiest way to reach the Mac's XQuartz server.
* **`xhost +localhost`**: By default, XQuartz blocks all incoming connections. This command opens a "hole" specifically for local network traffic (like the Podman VM).
* **`LIBGL_ALWAYS_SOFTWARE=1`**: XCrySDen uses OpenGL. XQuartz often struggles with hardware-accelerated OpenGL from containers; forcing software rendering ensures the GUI actually opens instead of crashing with a "glX" error.

#### Troubleshooting (Apple Silicon)
If you are running on an Apple Silicon Mac (M1/M2/M3), and the image is `x86_64` only, you will need to add the `--arch amd64` flag to your `podman run` command. Note that this emulation may have a performance impact.

---

## AI Assistant Instructions

If you are an AI assistant (like Gemini) making modifications to this repository, please review and abide by the guidelines established in [`gemini.md`](gemini.md).
