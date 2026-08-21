# homebrew-tap

Homebrew tap for [AnotherSava](https://github.com/AnotherSava)'s apps.

## Install

```sh
brew install --cask AnotherSava/tap/claude-code-dashboard
```

The tap is added automatically the first time you install from it — no separate `brew tap` step needed.

## Casks

- **claude-code-dashboard** — an always-on-top desktop widget that tracks the live status of Claude Code agent sessions. [Source](https://github.com/AnotherSava/claude-code-dashboard) · [Documentation](https://anothersava.github.io/claude-code-dashboard/)

## A note on Gatekeeper

The Claude Code Dashboard build is ad-hoc signed rather than notarized by Apple. macOS refuses to launch such an app while the quarantine attribute is set, reporting it as damaged. This cask removes that attribute after installing, which is the same step the [manual install guide](https://anothersava.github.io/claude-code-dashboard/pages/install) asks you to perform by hand.

That is a deliberate Gatekeeper bypass, so the checksum pinned in the cask is the only integrity check on the download. If you would rather macOS verify the app itself, install the DMG from the [releases page](https://github.com/AnotherSava/claude-code-dashboard/releases) instead and clear the attribute yourself.

Apple Silicon only — the upstream release ships an `aarch64` build.
