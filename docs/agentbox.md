# Per-agent Linux desktops

Agentbox gives each worker a separate Microsandbox microVM with its own Linux kernel, XFCE desktop under Xvfb, Chromium profile, CUA socket, work directory, and captures. It runs in the background, so the laptop's Hyprland desktop can stay locked or in use. Suspending the laptop pauses the VMs.

The VMs share the host hardware and Microsandbox runtime, but have separate guest disks and kernels. Agentbox does not mount the host home directory. It isolates the computer it controls; a provider's shell or file tools must also be routed through Agentbox to stay inside that VM.

## Install on Omarchy

Microsandbox needs hardware virtualization and a user-accessible `/dev/kvm`. This setup does not change Hyprland or install desktop packages on the host.

```sh
test -c /dev/kvm && test -r /dev/kvm && test -w /dev/kvm
curl -fsSL https://install.microsandbox.dev | sh
export PATH="$HOME/.local/bin:$PATH"
msb doctor
```

Install the Agentbox command from this checkout:

```sh
mkdir -p ~/.local/bin
ln -s "$PWD/examples/linux/agentbox/agentbox" ~/.local/bin/agentbox
```

The first seed boot provisions Debian with Chromium, XFCE, Xvfb, CUA Driver, and ffmpeg. It may take a few minutes. The defaults are 2 CPUs, 2 GiB memory, a 16 GiB guest disk, and public internet access. Set `AGENTBOX_CPUS`, `AGENTBOX_MEMORY`, `AGENTBOX_ROOT_DISK`, `AGENTBOX_IMAGE`, or `AGENTBOX_NETWORK_PROFILE` before the first `agentbox seed start`. Worker clones inherit the seed disk and network setup, plus its CPU and memory allocation.

## Sign in once, then clone

Open a dedicated login browser in the `main` VM. Connect your agent's CUA MCP client to the seed, or use the command line:

```sh
agentbox seed start
agentbox open main https://www.wikipedia.org
agentbox cua main list_windows '{}'
```

Sign into the websites needed for the work inside that browser. When finished, stop the seed to snapshot its browser profile:

```sh
agentbox seed stop
agentbox clone researcher-1
agentbox clone researcher-2
```

Each clone gets an independent writable disk copied from the stopped seed. A clone's later cookie changes do not sync to other clones. Refresh the seed and create new clones when credentials need updating.

Chromium is configured with its basic password store so the profile can be cloned without the laptop's desktop keyring. Treat the seed and every clone as credentials: anyone with access to a VM can use its signed-in sessions. Agentbox never copies the host browser profile or keyring.

## Connect an agent

Give each worker a unique ID. Configure its CUA MCP server as a stdio command using the absolute path to `agentbox`:

```json
{
  "mcpServers": {
    "computer-use": {
      "command": "/home/you/.local/bin/agentbox",
      "args": ["mcp", "researcher-1"]
    }
  }
}
```

Route terminal work through the same ID:

```sh
agentbox exec researcher-1 -- pwd
agentbox shell researcher-1
```

Other useful commands:

```sh
agentbox list
agentbox open researcher-1 https://www.wikipedia.org
agentbox open researcher-1 chrome://extensions
agentbox cua researcher-1 list_windows '{}'
agentbox stop researcher-1
agentbox remove researcher-1
```

An MCP connection and terminal command that use the same ID reach the same browser and workspace. Assign a different ID to every concurrently active worker. Provider-native filesystem and shell tools can still run on the host unless their configuration routes them through Agentbox; this CLI alone does not rewrite provider tool routing.

## Record a workflow

Use the same CUA MCP connection for the whole interaction. Prepare the target page first, start recording just before the UI action, and set `record_video` explicitly because CUA Driver defaults it to false:

```text
start_recording({"output_dir":"/home/agent/captures/extension-check","record_video":true})
```

Perform the interaction, capture and inspect the final UI state, then stop recording:

```text
stop_recording({})
```

Pull the guest capture onto the host while the VM is available:

```sh
agentbox record researcher-1 pull extension-check
```

Artifacts are saved under `~/.local/share/agentbox/instances/researcher-1/captures/` by default. Stop the worker when finished. The per-instance state can be relocated with `XDG_DATA_HOME`; runtime lock files live under `$XDG_RUNTIME_DIR/agentbox-client-locks/`.

## Runtime behavior and limits

- `agentbox seed stop` closes Chromium, stops the login seed, and creates a disk snapshot. Run it after signing in or refreshing credentials.
- Agentbox marks the seed dirty whenever it starts. If the VM stopped unexpectedly, `agentbox seed stop` snapshots the stopped disk; cloning refuses to use an older snapshot while the dirty marker remains.
- `agentbox clone <id>` requires the stopped seed snapshot and refuses an existing target. It clears the guest work and capture directories in the new clone.
- Stopping a worker preserves its guest disk and host-side pulled captures. Starting it resumes that worker's own VM and desktop.
- `agentbox remove <id>` deletes the worker VM but leaves pulled host captures in place.
- VMs can browse public internet by default. This is necessary for general websites but does not prevent a worker from reading or submitting data with the cloned browser credentials.
- Each VM is allocated real host RAM and disk. The laptop needs enough free memory for the host desktop plus every running worker.
- The local Microsandbox runtime and its VM process are shared host services. Provider tools that run outside the guest can bypass the VM boundary.

See the [Agentbox skill](../.agents/skills/agentbox/SKILL.md), the [design decision](agentbox-design.md), and Microsandbox's [snapshot documentation](https://microsandbox.dev/features/snapshots).
