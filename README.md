# nebelhaus/tap

Homebrew tap for the [nebelhaus](https://github.com/nebelhaus) family.

```sh
brew tap nebelhaus/tap
brew install pounce
```

| formula | what it is |
|---|---|
| [`pounce`](Formula/pounce.rb) | summon, aim, pounce — a native, scriptable command palette for macOS |

Formulae build from source (a single `swiftc` against system frameworks —
just the Xcode Command Line Tools Homebrew already requires).

**This repo is CI-owned.** Version bumps are pushed by each project's release
workflow when a `vX.Y.Z` tag lands (see
[pounce's `release.yml`](https://github.com/nebelhaus/pounce/blob/main/.github/workflows/release.yml));
humans only touch it to bootstrap a new formula. Issues and PRs about the
*software* belong in the project repos.
