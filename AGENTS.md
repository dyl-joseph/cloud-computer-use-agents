# AGENTS.md

## Repository map

- `.agents/skills/`: reusable computer-use, recording, and Agentbox instructions.
- `docs/`: setup and runtime guidance.
- `examples/linux/`: Linux background desktop and per-agent VM commands.
- `assets/screenshots/`: reviewed screenshots embedded in the README.

## Work style

Keep changes focused and preserve user data. Verify shell changes with syntax checks and verify GUI workflows in the actual isolated desktop. Keep generated recordings under ignored `recordings/` or `test-results/` paths; only add reviewed, intentional screenshots to `assets/screenshots/`.

Do not add commit attribution trailers for agents or models.

## Last Updated

2026-09-29 — implemented and verified the Microsandbox VM based Agentbox lifecycle, MCP, recording, and clone isolation.
2026-09-29 — added the reviewed Agentbox verification videos under `assets/videos/`; raw recordings remain ignored.
2026-09-29 — added versioned developer-tool provisioning, host-to-guest push support, and GitHub CLI seed guidance.
