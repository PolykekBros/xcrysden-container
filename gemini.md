---
description: System instructions and project guidelines for AI development agents
---

# Agent Guidelines for `xcrysden-container`

Welcome! If you are an AI assistant (like me) tasked with generating code, squashing bugs, or maintaining this repository, please strictly adhere to the following directives to ensure a smooth experience for the end user.

## 1. Cross-Platform Compatibility (macOS & Linux)
This is a containerized version of an X11-based GUI application (XCrySDen). The primary challenge is ensuring the GUI works flawlessly on both **Linux** and **macOS** hosts using **Podman**.

*   **Mandatory Requirement**: Any modifications to shell scripts (especially `run.sh`), Containerfiles/Dockerfiles, or build processes **must** be tested or logically verified to support both macOS (via Podman Machine + XQuartz) and Linux (via native X11).
*   **Do not break existing OS logic**: Ensure that `uname -s` conditionals tracking `Darwin` and `Linux` remain strictly respected. Do not blindly introduce commands that only exist on one OS (e.g., relying solely on `open` vs `xdg-open`).
*   **X11 Forwarding**: Keep in mind that macOS requires `host.containers.internal:0` and `LIBGL_ALWAYS_SOFTWARE=1`, whereas Linux usually works natively with `--net=host`, `--userns=keep-id` and `-e DISPLAY=$DISPLAY`.

## 2. Documentation is a Priority
*   **Update the README**: Whenever you change how a script runs, add new command-line arguments, modify the Containerfile, or introduce a new feature, you **MUST** update `README.md` to reflect these changes.
*   Keep the README structure clean, with distinct sections for different Operating Systems if the setup steps diverge.

## 3. Emphasize User-Friendliness (CLI Experience)
*   **Helper Scripts**: The primary entry point for users is `run.sh`. This script should be treated as a polished CLI tool.
*   **Visual Feedback**: Use emojis, clear structured output, and ANSI color codes (`\033[...]`) when writing `bash` output to guide the user. 
*   **Graceful Failures**: If a dependency is missing (e.g., `podman` or `XQuartz`), fail gracefully with a helpful, descriptive error message rather than a raw bash traceback.
*   **Automatic Hand-holding**: If the user forgets a step (such as not opening XQuartz), the script should either warn them gracefully or interactively resolve it (e.g., `open -a XQuartz`).

By following these fundamental guidelines, you ensure that the application remains stable and highly accessible for all end-users!
