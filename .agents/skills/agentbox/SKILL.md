---
name: agentbox
description: Agentbox routes an agent's Linux browser, GUI, terminal, and recordings through its own Microsandbox microVM.
---

# Agentbox

Use this skill when an agent needs an isolated Linux browser, GUI, terminal, or recording workspace on an Omarchy or other KVM Linux host.

Read the [Agentbox setup guide](../../../docs/agentbox.md) if Microsandbox or Agentbox is not installed yet.

## Give each worker one ID

Assign a unique ID to every concurrently active worker. Use the same ID for its CUA MCP connection and guest terminal:

```sh
agentbox mcp researcher-1
agentbox exec researcher-1 -- pwd
agentbox shell researcher-1
```

Each ID selects one VM, Linux guest kernel, XFCE/Xvfb desktop, Chromium profile, CUA socket, work directory, and capture directory. The laptop's Hyprland screen can remain locked or in use; suspending the laptop pauses the VMs.

## Seed signed-in browser state

Sign into websites inside the dedicated seed, then stop it and create worker VMs:

```sh
agentbox seed start
agentbox open main https://www.wikipedia.org
# Operate the seed through its CUA connection and sign in.
agentbox seed stop
agentbox clone researcher-1
agentbox clone researcher-2
```

Never copy the host browser profile or keyring. Each worker receives an independent clone of the seed's Chromium profile. Treat each clone as a credential because it can use the seed's signed-in sessions. Cookie changes do not sync between workers.

## Record and export

Use one persistent CUA MCP connection for the interaction. Prepare the target first, then start CUA Driver recording immediately before the UI action with video enabled explicitly:

```text
start_recording({"output_dir":"/home/agent/captures/extension-check","record_video":true})
```

After the first clear success state, capture it and stop recording:

```text
stop_recording({})
```

Pull the artifacts to the host:

```sh
agentbox record researcher-1 pull extension-check
```

Review screenshots and a representative video frame before reporting. Keep clips focused and short.

## Isolation boundary

The guest disk and kernel are separate per VM, and Agentbox does not mount the host home directory. Public internet is enabled by default. The Microsandbox runtime is shared on the host. Provider-native shell and filesystem tools can bypass the guest unless the provider routes them through Agentbox too.
