# nebelhaus/tap

Homebrew tap for the [nebelhaus](https://github.com/nebelhaus) family.

```sh
brew tap nebelhaus/tap
brew install pounce           # formula (builds from source)
brew install --cask trill     # cask (prebuilt app)
```

| formula | what it is |
|---|---|
| [`pounce`](Formula/pounce.rb) | summon, aim, pounce — a native, scriptable command palette for macOS |

| cask | what it is |
|---|---|
| [`trill`](Casks/trill.rb) | your Messages, native — a provider-neutral iMessage/SMS/RCS client for macOS |

Formulae build from source (a single `swiftc` against system frameworks — just
the Xcode Command Line Tools Homebrew already requires). Casks ship a prebuilt
`.app` from the project's GitHub release (signed, not notarized — right-click →
Open once to clear Gatekeeper).

**This repo is CI-owned.** Version bumps are pushed by each project's release
workflow when a `vX.Y.Z` tag lands (see
[pounce's `release.yml`](https://github.com/nebelhaus/pounce/blob/main/.github/workflows/release.yml));
humans only touch it to bootstrap a new formula or cask. Issues and PRs about
the *software* belong in the project repos.
