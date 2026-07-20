class Pounce < Formula
  desc "Summon, aim, pounce - a native, scriptable command palette for macOS"
  homepage "https://github.com/nebelhaus/pounce"
  version "2026.07.19-4"
  url "https://github.com/nebelhaus/pounce/releases/download/v#{version}/pounce-v#{version}-macos.tar.gz"
  sha256 "528282d62122d34a2185235bc72d852ef214a2da96f73bf31ad25c8d35e8e4e5"
  license "MIT"

  # The version/sha256 lines above are CI-owned: pounce's release workflow
  # rewrites them on every date-versioned tag (nebelhaus/pounce, release.yml) and
  # pushes here over a deploy key. Hand-edit only to bootstrap.
  livecheck do
    url :stable
    strategy :github_latest
  end

  # The release ships a prebuilt Pounce.app, signed with our Developer ID and
  # notarized — arm64 only, matching the nix aarch64-darwin target.
  depends_on arch: :arm64
  depends_on macos: :sonoma

  def install
    # Prebuilt bundle from the release tarball: Pounce.app is already signed with
    # our Developer ID and notarized (nebelhaus/pounce, release.yml). We only
    # place it and the command scripts — no compile step anymore.
    prefix.install "Pounce.app"
    bin.install_symlink prefix/"Pounce.app/Contents/MacOS/pounce"
    bin.install "ports"

    # The built-in command set, discovered by pounce-palette at runtime
    # (keg layout: <bin>/../share/pounce/commands is the script's default).
    (pkgshare/"commands").install Dir["commands/*.sh"]
    (pkgshare/"commands").install_symlink bin/"ports" => "ports.sh"
    bin.install "pounce-palette"

    # pounce-<id> wrappers, mirroring the Nix package (hotkey-friendly bins).
    Dir[pkgshare/"commands/*.sh"].map { |f| File.basename(f, ".sh") }.each do |id|
      (bin/"pounce-#{id}").write <<~SH
        #!/bin/bash
        export PATH="#{opt_bin}:$PATH"
        exec "#{opt_pkgshare}/commands/#{id}.sh" "$@"
      SH
      (bin/"pounce-#{id}").chmod 0555
    end
  end

  service do
    # Mirrors the launchd agent the nebelhaus rice runs: the daemon holds the
    # window, clipboard history, and the Accessibility grant. Run the binary
    # inside the bundle (not the bin symlink) so Bundle.main resolves.
    run [opt_prefix/"Pounce.app/Contents/MacOS/pounce", "--daemon"]
    keep_alive true
    process_type :interactive
    log_path var/"log/pounce.log"
    error_log_path var/"log/pounce.log"
    environment_variables LANG: "en_US.UTF-8"
  end

  def caveats
    <<~EOS
      Start the palette daemon:
        brew services start pounce

      The daemon registers the hotkey itself - Cmd+Space by default. macOS
      gives Cmd+Space to Spotlight, so free it up first (System Settings ->
      Keyboard -> Keyboard Shortcuts -> Spotlight) or pick another combo in
      ~/.config/pounce/config.json ("hotkey"). Prefer an external hotkey tool
      (skhd, AeroSpace, ...)? Set hotkey.enabled to false there and bind your
      key to `pounce-palette` instead.

      Grant Accessibility (for clipboard auto-paste and emoji paste-back):
        pounce --request-accessibility
      The app is signed with a stable Developer ID, so this grant now persists
      across upgrades (it no longer has to be re-granted after each release).

      Your own commands go in ~/.config/pounce/commands - one self-describing
      shell script per command, no registry, no rebuild.
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/pounce --version")
  end
end
