# typed: false
# frozen_string_literal: true

# Homebrew formula for `peeroxide`, the CLI for the peeroxide P2P stack.
#
# Distribution: prebuilt binaries from the per-target archives attached to
# `peeroxide-cli-v*` GitHub Releases on Rightbracket/peeroxide. The archives
# are produced by the `binary-release.yml` workflow in that repo.
#
# Bumping this formula is automated: the `auto-bump.yml` workflow in this
# tap polls upstream Releases on a daily schedule (and on-demand) and
# opens a PR updating the URL and sha256 lines below. The `peeroxide-cli`
# version is parsed by Homebrew out of the URL paths, so there is no
# explicit `version` line to keep in sync.
#
# macOS uses a single universal (arm64 + x86_64) fat binary. Linux uses
# per-architecture archives selected via `on_linux` + `on_arm`/`on_intel`.
#
# Users who want a from-source build can run:
#   brew install --HEAD rightbracket/peeroxide/peeroxide
class Peeroxide < Formula
  desc "Hyperswarm DHT P2P CLI from peeroxide: chat, copy (cp), deaddrop (dd), node"
  homepage "https://github.com/Rightbracket/peeroxide"
  url "https://github.com/Rightbracket/peeroxide/releases/download/peeroxide-cli-v0.1.0/peeroxide-0.1.0-universal-apple-darwin.tar.gz"
  sha256 "eda6c509fc1ca0b85d5fac6bc53ad8ab76304e1c4e59453af5d6f05f55d2eaf2" # universal-apple-darwin
  license any_of: ["MIT", "Apache-2.0"]

  # Track the newest `peeroxide-cli-v*` GitHub release. The workspace also
  # publishes `peeroxide-v*`, `peeroxide-dht-v*`, and `libudx-v*` tags; we
  # filter to the CLI tags via regex so livecheck does not report version
  # drift against the library crates.
  livecheck do
    url :stable
    regex(/^peeroxide-cli-v?(\d+(?:\.\d+)+)$/i)
    strategy :github_releases
  end

  # Optional from-source build path. `brew install --HEAD ...` uses this.
  head do
    url "https://github.com/Rightbracket/peeroxide.git", branch: "main"
    depends_on "rust" => :build
  end

  on_linux do
    on_arm do
      url "https://github.com/Rightbracket/peeroxide/releases/download/peeroxide-cli-v0.1.0/peeroxide-0.1.0-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "f7aeba41449e658dea929d81b40055a3adc0b8b0e05b7cec51a2f64121b9aa01" # aarch64-unknown-linux-gnu
    end
    on_intel do
      url "https://github.com/Rightbracket/peeroxide/releases/download/peeroxide-cli-v0.1.0/peeroxide-0.1.0-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "7a9c178d48c74dcc337b8ff20b00da5d3d4c0a00663215fb683ad90ba79a781c" # x86_64-unknown-linux-gnu
    end
  end

  def install
    if build.head?
      system "cargo", "install", *std_cargo_args(path: "peeroxide-cli")
    else
      bin.install "peeroxide"

      # Bundled docs are nice-to-have; only install what the archive ships.
      pkgshare.install "README.md"      if File.exist?("README.md")
      pkgshare.install "LICENSE-MIT"    if File.exist?("LICENSE-MIT")
      pkgshare.install "LICENSE-APACHE" if File.exist?("LICENSE-APACHE")
    end

    # Upstream archives ship pre-generated man pages under man/man1/.
    # Guarded so an archive without them does not fail the install.
    man1.install Dir["man/man1/*.1"] if Dir.exist?("man/man1")
  end

  def caveats
    <<~EOS
      To generate default configuration files, run:
        peeroxide init

      This step is optional but recommended.
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/peeroxide --version")
    assert_match "peeroxide",  shell_output("#{bin}/peeroxide --help")
  end
end
