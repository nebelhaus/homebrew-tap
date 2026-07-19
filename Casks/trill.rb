cask "trill" do
  version "0.1.4"
  sha256 "ada1cabf1aa9ab4e3d79a2413feef8cceab7a1673d6f3f26369d53bbe8626e84"

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

  # Trill is signed with our Developer ID and notarized by Apple (nebelhaus/trill,
  # release.yml), so Gatekeeper clears it on first launch — no quarantine hack.

  caveats <<~EOS
    The live Messages provider reads ~/Library/Messages/chat.db (always
    read-only) and needs Full Disk Access. Grant it once in System Settings ->
    Privacy & Security -> Full Disk Access (add Trill). Fixture mode needs
    no permissions at all.
  EOS
end
