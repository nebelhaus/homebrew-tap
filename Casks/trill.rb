cask "trill" do
  version "2026.07.19"
  sha256 "296cab920f86079d76d18e5afd6254860943f7200e50c5b28db317119fa49a9c"

  url "https://github.com/nebelhaus/trill/releases/download/v#{version}/trill-v#{version}-macos.zip"
  name "Trill"
  desc "Native, provider-neutral macOS Messages client (iMessage/SMS/RCS)"
  homepage "https://github.com/nebelhaus/trill"

  # The version/sha256 lines above are CI-owned: trill's release workflow
  # rewrites them on every date-versioned tag (nebelhaus/trill, release.yml) and pushes
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
