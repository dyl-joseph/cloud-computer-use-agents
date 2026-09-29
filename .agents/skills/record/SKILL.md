---
name: record
description: Capture visual evidence while reproducing or verifying user-facing behavior. Use screenshots for key UI states and cursor-visible recordings when the interaction sequence or full pipeline needs review.
---

# Record visual evidence

Use this skill when reproducing or visually verifying UI behavior, or when the user asks to capture a workflow. Skip recording for code-only work where no visible behavior is being reproduced.

## Choose the capture

- Capture screenshots for the reproduced state and any meaningful before/after state. Save the real application surface at the relevant viewport, then inspect the image. Include browser chrome when browser integration is part of the behavior under test. For example, test a Chrome extension in its actual side panel; label a direct `chrome-extension://` page capture as page-only.
- Capture a video when the user asks for one or when action order, timing, navigation, or handoffs make the full pipeline important. Finish environment setup first, then start recording immediately before opening or launching the target app or extension. For a browser extension, prepare the browser and target page before recording, then start just before opening the extension UI. Keep the agent cursor visible so the actions can be followed.
- Once the expected end state is visible, take the verification screenshot and stop recording immediately. Keep setup, troubleshooting, and idle waits outside the clip. If an attempt stalls, stop that recording, resolve the issue, and make a fresh capture of the user-visible interaction.
- For a simple app-open or extension-open verification, keep the recorded interaction under one minute. If it cannot be completed in that time, stop and report the blocker instead of extending the clip.
- Use an installed GUI driver, such as CUA Driver, for native apps and browser chrome when available. Read that driver's recording instructions for its current commands, artifact layout, and platform limits. Follow its snapshot-before-action and delivery rules; do not escalate to foreground input without authorization.
- For browser-only behavior, use the available browser automation's screenshot or video capture. Describe it as page capture when it does not include the browser's native UI.
- If the user's desktop must remain locked or untouched, capture in an isolated browser profile or virtual display. Do not send input to the user's locked session.

## Fast path: one UI action

- Before recording, verify the exact GUI endpoint, target window, and ready control in one fresh snapshot. Finish setup such as pinning the extension before capture.
- Use browser accessibility refs or DevTools for page content and diagnosis; reserve GUI control for browser chrome and native UI. Avoid full DOM dumps and repeated screenshots.
- On one persistent GUI connection, start recording, perform the action, wait for one observable postcondition (no fixed sleep), capture the final screenshot, then stop.
- Use one controller for a single linear UI flow. If the user specifies a worker model, give it only the ready-state facts, action, success evidence, and stop limit; request a concise result.

## Keep and report evidence

- Write artifacts to the repository's existing test-results or artifact directory. Otherwise use `test-results/record/<run-id>/`.
- Keep the original screenshots and recordings after the run. Check that each expected file exists and is non-empty; visually inspect screenshots and representative video frames.
- Link the evidence in the final response and report only the result, duration, and artifact paths. Do not describe a page screenshot as proof of browser chrome, an extension panel, or a native permission prompt that it does not contain.
- Avoid capturing unrelated private content. Use a fixture or isolated profile when it gives the same visual proof without exposing personal data.
