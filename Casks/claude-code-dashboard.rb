cask "claude-code-dashboard" do
  version "1.16.0"
  sha256 "b91375177138aa96fcf250e7318c4136981439e4bca1dd113d0eaef3f944f6d4"

  url "https://github.com/AnotherSava/claude-code-dashboard/releases/download/v#{version}/Claude.Code.Dashboard_#{version}_aarch64.dmg"
  name "Claude Code Dashboard"
  desc "Always-on-top widget tracking live status of Claude Code agent sessions"
  homepage "https://github.com/AnotherSava/claude-code-dashboard"

  livecheck do
    url :url
    strategy :github_latest
  end

  # The macOS release job runs on macos-latest with no --target, so the binary
  # is Mach-O thin arm64. Drop this only if the build goes universal.
  depends_on arch: :arm64
  depends_on macos: :big_sur

  app "Claude Code Dashboard.app"

  # The build is ad-hoc signed (bundle.macOS.signingIdentity = "-"), so the
  # com.apple.quarantine attribute Homebrew always applies makes macOS refuse
  # to launch it as "damaged and can't be opened". This runs the same removal
  # the manual install guide asks users to perform by hand.
  #
  # -dr, not -cr: the strip must be recursive because Homebrew writes the
  # attribute onto every file in the bundle, and it must name the attribute
  # because -c would also clear com.apple.provenance.
  #
  # This is a deliberate Gatekeeper bypass; the sha256 above is then the only
  # integrity check on the download. The durable fix is a Developer ID
  # signature plus notarization, after which this block should be deleted.
  # The launch has to come after the strip or macOS refuses it. It is also
  # deliberate: this is a menu-bar app with no Dock icon, so an install that
  # ends without starting it leaves nothing on screen and nothing to click.
  # The `|| true` is what keeps a refused launch from failing an otherwise good
  # install. The `must_succeed: false` keyword would read better but does not
  # exist in released Homebrew (6.0.18) -- only on newer git checkouts -- and an
  # unknown keyword makes the whole cask unreadable, so `brew install` fails
  # outright rather than degrading. Shelling out is version-agnostic.
  postflight_steps do
    run "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "{{appdir}}/Claude Code Dashboard.app"]
    run "/bin/sh", args: ["-c", "/usr/bin/open '{{appdir}}/Claude Code Dashboard.app' || true"]
  end

  # The autostart LaunchAgent is labelled after the product name, spaces and
  # all -- not the bundle id (tauri-plugin-autostart names it from
  # package_info().name). Quitting matters: the tray process holds
  # 127.0.0.1:9077, and a second instance that fails to bind runs silently
  # deaf.
  uninstall launchctl: "Claude Code Dashboard",
            quit:      "com.anothersava.claude-code-dashboard",
            signal:    [["KILL", "com.anothersava.claude-code-dashboard"]]

  # Order here comes from the key, not from the file: Homebrew runs launchctl,
  # then script, then delete, then trash. That ordering is load-bearing --
  # clearing the pmset flag MUST happen before the sudoers grant and the
  # boot-reset daemon are removed. The lid-awake veto survives reboot, and all
  # three of its recovery paths depend on those two files, so deleting them
  # first leaves a Mac that can never sleep again.
  #
  # Deliberately NOT zapped: the "Claude Code-credentials" keychain item. The
  # app writes to it (usage_limits.rs) but it belongs to Claude Code itself,
  # and removing it would log the user out of Claude Code.
  zap launchctl: "com.anothersava.claude-code-dashboard.sleepreset",
      script:    {
        executable: "/usr/bin/pmset",
        args:       ["-a", "disablesleep", "0"],
        sudo:       true,
      },
      delete:    [
        "/etc/sudoers.d/claude-code-dashboard-lidawake",
        "/Library/LaunchDaemons/com.anothersava.claude-code-dashboard.sleepreset.plist",
      ],
      trash:     [
        "~/Library/Application Support/com.anothersava.claude-code-dashboard",
        "~/Library/Caches/com.anothersava.claude-code-dashboard",
        "~/Library/LaunchAgents/Claude Code Dashboard.plist",
        "~/Library/Preferences/com.anothersava.claude-code-dashboard.plist",
        "~/Library/Saved Application State/com.anothersava.claude-code-dashboard.savedState",
        "~/Library/WebKit/com.anothersava.claude-code-dashboard",
      ]

  caveats <<~EOS
    The widget stays empty until you add its hook to ~/.claude/settings.json.
    It shows the exact snippet to paste on first run:
      https://anothersava.github.io/claude-code-dashboard/pages/install

    Not notarized by Apple, so this cask cleared the quarantine flag for you.
  EOS
end
