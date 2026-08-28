# Global instructions

Personal, machine-wide guidance for Claude Code. Applies to every session
regardless of working directory.

## Browser

- Default to Chrome for Claude (the `/chrome` command / `open -a "Google Chrome"`)
  for anything it can do: opening URLs, navigating, reading pages, clicking,
  filling forms, screenshots.
- Fall back to the chrome-devtools MCP only for what Chrome for Claude can't do —
  e.g. performance traces, network-request inspection, console/heap analysis,
  device emulation.
