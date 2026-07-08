class Pounce < Formula
  desc "Summon, aim, pounce - a native, scriptable command palette for macOS"
  homepage "https://github.com/nebelhaus/pounce"
  url "https://github.com/nebelhaus/pounce/releases/download/v0.4.1/pounce-src-v0.4.1.tar.gz"
  sha256 "3e65b905423da1167b9374da8a7231d7ff080383ed6ffd077443fa1521f1e9f5"
  license "MIT"

  # The url/sha256 lines above are CI-owned: pounce's release workflow
  # rewrites them on every vX.Y.Z tag (nebelhaus/pounce, release.yml) and
  # pushes here over a deploy key. Hand-edit only to bootstrap.
  livecheck do
    url :stable
    strategy :github_latest
  end

  depends_on :macos

  def install
    # Same compile + bundle assembly as the Nix derivation (pkgs/pounce/build.sh
    # is the shared single source of truth). Needs only the Xcode CLT swiftc.
    ENV["POUNCE_VERSION"] = version.to_s
    system "bash", "pkgs/pounce/build.sh"

    prefix.install "pkgs/pounce/Pounce.app"
    bin.install_symlink prefix/"Pounce.app/Contents/MacOS/pounce"
    bin.install "pkgs/pounce/ports"

    # The built-in command set, discovered by pounce-palette at runtime
    # (keg layout: <bin>/../share/pounce/commands is the script's default).
    (pkgshare/"commands").install Dir["pkgs/pounce-commands/commands/*.sh"]
    (pkgshare/"commands").install_symlink bin/"ports" => "ports.sh"
    bin.install "pkgs/pounce-commands/pounce-palette"

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

      Grant Accessibility (the daemon places its window over the frontmost app):
        pounce --request-accessibility
      Re-run that after every upgrade: the binary is ad-hoc signed, so its
      code identity (and the TCC grant) changes with each rebuild.

      Then bind a hotkey to `pounce-palette` in your hotkey tool
      (skhd, AeroSpace exec-and-forget, ...).

      Your own commands go in ~/.config/pounce/commands - one self-describing
      shell script per command, no registry, no rebuild.
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/pounce --version")
  end
end
