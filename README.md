# homebrew-peeroxide

[Homebrew](https://brew.sh) tap for [**peeroxide**](https://github.com/Rightbracket/peeroxide) — the Rust implementation of the Hyperswarm P2P networking stack.

This tap distributes the peeroxide CLI suite as prebuilt binaries for
macOS and Linux. No Rust toolchain is required to install.

The `peeroxide` binary is a multitool exposing several Hyperswarm-DHT
P2P subcommands. The core user-facing commands are:

| Subcommand | Purpose                                                       |
| ---------- | ------------------------------------------------------------- |
| `chat`     | Peer-to-peer chat over the Hyperswarm DHT                      |
| `cp`       | Copy files between peers                                       |
| `deaddrop` | Anonymous store-and-forward drop / pickup of payloads          |
| `node`     | Run a long-running Hyperswarm DHT bootstrap node               |

Additional DHT primitives (`announce`, `lookup`, `ping`) and configuration
helpers (`config`) are also available. Run `peeroxide --help` for the
complete subcommand list.

## Install

```sh
brew install rightbracket/peeroxide
```

Homebrew expands this shorthand to `brew install rightbracket/peeroxide/peeroxide`
because the formula name matches the tap name.

Or tap first and install later:

```sh
brew tap rightbracket/peeroxide
brew install peeroxide
```

## Supported platforms

Prebuilt binaries are published for:

| Platform                                | Target triple                  |
| --------------------------------------- | ------------------------------ |
| macOS (universal: Apple Silicon + Intel) | `universal-apple-darwin`       |
| Linux, x86_64 (glibc)                   | `x86_64-unknown-linux-gnu`     |
| Linux, aarch64 (glibc)                  | `aarch64-unknown-linux-gnu`    |

The macOS archive is a fat binary containing both `arm64` and `x86_64`
slices, so the same install works on Apple Silicon and Intel Macs without
a second download.

Each archive is built by the
[`binary-release.yml`](https://github.com/Rightbracket/peeroxide/blob/main/.github/workflows/binary-release.yml)
workflow in the upstream repository and attached to the matching
`peeroxide-cli-v*` GitHub Release.

## Build from source

If you prefer to compile locally, install the `HEAD` formula. This pulls
the latest `main` branch of `Rightbracket/peeroxide` and builds via
`cargo install`, so a Rust toolchain is required:

```sh
brew install --HEAD rightbracket/peeroxide
```

## Upgrade

```sh
brew update
brew upgrade peeroxide
```

## Uninstall

```sh
brew uninstall peeroxide
brew untap rightbracket/peeroxide
```

## Usage

```sh
peeroxide --help
peeroxide chat --help
peeroxide cp --help
peeroxide deaddrop --help
peeroxide node --help
```

See the [main repository](https://github.com/Rightbracket/peeroxide) for
full CLI documentation, configuration, and protocol details.

## How releases reach this tap

1. Upstream tags a new `peeroxide-cli-v<VERSION>` release.
2. The `binary-release.yml` workflow in
   [`Rightbracket/peeroxide`](https://github.com/Rightbracket/peeroxide)
   builds the four target binaries and attaches them (with `.sha256`
   sidecars) to the GitHub Release.
3. This tap's [`auto-bump.yml`](.github/workflows/auto-bump.yml) workflow
   polls upstream Releases daily (and can be triggered on demand via
   **Actions → auto-bump → Run workflow**). When it finds a new version, it
   downloads the sidecars, rewrites `Formula/peeroxide.rb`, and opens a
   same-repo PR.
4. [`ci.yml`](.github/workflows/ci.yml) installs the new formula on
   `macos-14`, `macos-13`, and `ubuntu-latest` and runs `brew test`.
5. [`auto-merge.yml`](.github/workflows/auto-merge.yml) squash-merges the
   PR once required checks pass, provided it only modifies the formula.

The entire flow uses the per-run `GITHUB_TOKEN`. No personal access
tokens, no rotating secrets.

## License

The formula and tap content are MIT-licensed. The upstream `peeroxide-cli`
crate is dual-licensed under
[MIT](https://github.com/Rightbracket/peeroxide/blob/main/LICENSE-MIT) OR
[Apache-2.0](https://github.com/Rightbracket/peeroxide/blob/main/LICENSE-APACHE).
