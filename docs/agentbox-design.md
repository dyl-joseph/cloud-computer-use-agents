# Agentbox runtime decision

## Decision

Use Microsandbox to create one local KVM microVM per worker. A named VM gives the worker an independent guest kernel, disk, Chromium profile, XFCE/Xvfb desktop, CUA socket, work directory, and recording directory. A stopped `main` login VM is the source of disk snapshots for worker clones.

Microsandbox was exercised on the Omarchy host: `/dev/kvm` is accessible, the user-level CLI boots guests, disk snapshots restore into separate VMs, public websites load from the guest, and Chromium can be driven and recorded through CUA Driver. The screenshot and short browser-navigation video in the repository were captured from that VM.

## Why this runtime

The main requirement is a distinct, reusable computer per agent, including a browser profile that can be seeded once and copied without touching the host's profile or keyring. Microsandbox exposes local VM creation, snapshot, and restore operations directly, and `msb exec --stream` provides the byte-preserving stdio channel needed for a CUA MCP server. Agentbox adds a small stable CLI over those primitives.

OpenShell remains a viable alternative when its policy gateway and managed agent lifecycle are central requirements. Its documentation describes container and VM runtimes and network allowlists; the VM runtime is documented as experimental. This implementation favors the local snapshot-and-clone loop already verified on this host. That is a scope decision, not a claim that OpenShell cannot provide per-agent VMs or browser access.

## Browser credentials and tool boundary

Chromium's basic password store makes a stopped profile cloneable without the host desktop keyring. A clone contains usable browser credentials, so only assign it to a trusted worker. Clones diverge after creation; refresh the seed and make new clones to update them.

Agentbox owns the guest GUI, browser, and terminal entry points, but does not configure Codex, Claude Code, OpenCode, or another provider's native shell and filesystem tools. Those tools must be explicitly routed through the same instance if they need to stay inside its VM. The host Microsandbox runtime remains shared.

## References

- [Microsandbox snapshots](https://microsandbox.dev/features/snapshots)
- [Microsandbox CLI sandbox commands](https://github.com/superradcompany/microsandbox/blob/main/docs/cli/sandbox-commands.mdx)
- [OpenShell sandbox runtimes](https://docs.nvidia.com/openshell/latest/how-it-works/sandboxes/runtimes)
- [OpenShell network policy schema](https://docs.nvidia.com/openshell/latest/how-it-works/policies/schema)
