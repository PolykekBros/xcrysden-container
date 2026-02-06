# XCrySDen Container

How to run

## 1. Directly with `run.sh`

```console
>  curl -sSL https://raw.githubusercontent.com/PolykekBros/xcrysden-container/main/run.sh | sh
```

## 2. Manually

### Step 1. Build

```console
> podman build -t xcrysden https://github.com/PolykekBros/xcrysden-container.git
```

### Step 2. Run

This is maybe required on fedora system

```console
> xhost +SI:localuser:$(whoami)
```

```console
> podman run --rm -it \
          --net=host \
          -e DISPLAY=$DISPLAY \
          -v /tmp/.X11-unix:/tmp/.X11-unix:ro \
          -v $HOME:$HOME \
          --userns=keep-id \
          xcrysden
```
