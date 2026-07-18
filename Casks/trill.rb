cask "trill" do
  version "0.1.3"
  sha256 "4b446196c1df94175475d02b0c654905a940dbe4be25444b8f2c84259299e663"

  url "https://github.com/nebelhaus/trill/releases/download/v#{version}/trill-v#{version}-macos.zip"
  name "Trill"
  desc "Native, provider-neutral macOS Messages client (iMessage/SMS/RCS)"
  homepage "https://github.com/nebelhaus/trill"

  # The version/sha256 lines above are CI-owned: trill's release workflow
  # rewrites them on every vX.Y.Z tag (nebelhaus/trill, release.yml) and pushes
  # here over a deploy key. Hand-edit only to bootstrap.
  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on macos: :sonoma

  app "Trill.app"

  # Trill is ad-hoc signed, not notarized, so a quarantined copy trips
  # Gatekeeper's "can't be verified / Move to Trash" dialog on first launch.
  # Since these are our own trusted builds, strip the quarantine flag right
  # after install so the app opens straight away — no right-click -> Open.
  postflight do
    system_command "/usr/bin/xattr",
                   args: ["-dr", "com.apple.quarantine", "#{appdir}/Trill.app"]
  end

  caveats <<~EOS
    Trill is signed but not notarized. This cask clears the Gatekeeper
    quarantine flag on install, so it opens straight away. If macOS still
    blocks it, clear the flag by hand:
      xattr -dr com.apple.quarantine "#{appdir}/Trill.app"

    The live Messages provider reads ~/Library/Messages/chat.db (always
    read-only) and needs Full Disk Access. Grant it once in System Settings ->
    Privacy & Security -> Full Disk Access (add Trill). Fixture mode needs
    no permissions at all.
  EOS
end
