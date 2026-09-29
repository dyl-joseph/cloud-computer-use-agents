# Isolated Linux desktop for background computer use

An Xvfb desktop gives an agent a separate X11 session. It can keep running while the person uses or locks a Hyprland, GNOME, or KDE session. Locking the physical screen does not lock the separate Xvfb display. Suspending the laptop pauses both.

This example starts Xvfb, a private D-Bus session, XFCE, and a CUA Driver daemon on a private Unix socket. It does not unlock the physical desktop or share its browser profile.

## Prerequisites

Install the distro packages that provide `xvfb-run`, `dbus-run-session`, and XFCE's `startxfce4`. Install CUA Driver with its [official instructions](https://cua.ai/docs/cua-driver). Check the package names and executable paths for your distribution.

The example assumes the `cua-driver` executable is in `~/.local/bin`. If it is elsewhere, set `CUA_DRIVER_BIN` in the user service or update the `PATH` in the unit file.

## Install the user service

Copy the examples into the user configuration directories:

```sh
mkdir -p ~/.config/systemd/user ~/.local/bin
cp examples/linux/cua-background-xfce.service ~/.config/systemd/user/
cp examples/linux/cua-xfce-session ~/.local/bin/
chmod 755 ~/.local/bin/cua-xfce-session
systemctl --user daemon-reload
systemctl --user enable --now cua-background-xfce.service
```

If the user service manager stops at logout and the desktop should remain available between logins, enable user lingering:

```sh
sudo loginctl enable-linger "$(id -un)"
```

Check the service and socket:

```sh
systemctl --user status cua-background-xfce.service
printf 'CUA socket: %s/cua-background-xfce/cua.sock\n' "$XDG_RUNTIME_DIR"
```

Use the explicit socket for every CUA call. A default endpoint may point at a different desktop:

```sh
CUA_SOCKET="$XDG_RUNTIME_DIR/cua-background-xfce/cua.sock"
cua-driver list_windows '{}' --socket "$CUA_SOCKET"
cua-driver get_desktop_state '{"screenshot_out_file":"/tmp/cua-desktop.png"}' --socket "$CUA_SOCKET"
```

The window list should name the isolated XFCE desktop. Check that it contains the target Chromium or application window before sending input.

## Launch Chromium in the isolated session

Prefer `launch_app` through the same CUA socket. The CUA daemon inherits the display created by `xvfb-run`:

```sh
CUA_SOCKET="$XDG_RUNTIME_DIR/cua-background-xfce/cua.sock"
cua-driver launch_app '{"launch_path":"/usr/bin/chromium"}' --socket "$CUA_SOCKET"
cua-driver list_windows '{}' --socket "$CUA_SOCKET"
```

Use an isolated browser profile unless the task needs a login and the user explicitly asks to use a trusted existing profile. For a browser launched directly from a shell, use the X11 display from the isolated session, unset `WAYLAND_DISPLAY`, and set `--ozone-platform=x11`; otherwise Chromium may try to connect to the physical Wayland session. Do not use `--no-sandbox` unless Chromium reports a specific sandbox failure and the isolated environment justifies that tradeoff.

## Service behavior

- `systemctl --user enable --now` starts the isolated desktop at user login and restarts it after a failure.
- The service's runtime directory holds `cua.sock`; the directory is private to the user.
- Locking the physical desktop leaves Xvfb independent. Laptop sleep or hibernation pauses the agent desktop until resume.
- Stop the isolated desktop with `systemctl --user disable --now cua-background-xfce.service`.
- Keep screenshots and browser profiles separate from personal files. Do not use `xhost +` or route input to the physical desktop to solve a virtual-display issue.
