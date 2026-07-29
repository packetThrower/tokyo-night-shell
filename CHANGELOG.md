# Changelog

## 0.2.0 — 2026-07-29

- New `mode` command: force dark or day without changing the macOS
  Appearance setting. `tokyo-night-shell mode dark|day|light|auto`; no
  argument prints the current setting. WezTerm repaints immediately,
  Starship follows on the next prompt, Zellij applies to new sessions.
- README reworked: install-first layout, table of contents, plainer prose.

## 0.1.0 — 2026-06-03

Initial release.

- Coordinated Tokyo Night theme for WezTerm, Starship, and Zellij that
  follows the macOS light/dark setting live, with a day palette tuned for
  vibrancy/blur.
- Single `tokyo-night-shell` CLI with `init`, `uninstall`, and `swap`
  subcommands.
- Accent swap across all three tools: blue, cyan, magenta, green, yellow,
  red, orange.
- Homebrew formula at `packetthrower/tap/tokyo-night-shell`.
