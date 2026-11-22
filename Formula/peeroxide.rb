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
  url "https://github.com/Rightbracket/peeroxide/releases/download/peeroxide-cli-v0.3.3/peeroxide-0.3.3-universal-apple-darwin.tar.gz"
  sha256 "010f409f329f02dbe9a035f91c00e91e1425b7a2349fb1f287dfd217eccafef5" # universal-apple-darwin
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
      url "https://github.com/Rightbracket/peeroxide/releases/download/peeroxide-cli-v0.3.3/peeroxide-0.3.3-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "5a487a3940154b8d3c5e97953b70ae548b4e67160f10b5f37e01fae3e90d21a2" # aarch64-unknown-linux-gnu
    end
    on_intel do
      url "https://github.com/Rightbracket/peeroxide/releases/download/peeroxide-cli-v0.3.3/peeroxide-0.3.3-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "274b8b00ff7133bd41b20553a087fdd758d4b61e48eb80e142e71d9bd636b788" # x86_64-unknown-linux-gnu
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
