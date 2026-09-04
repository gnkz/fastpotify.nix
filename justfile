set shell := ["bash", "-euo", "pipefail", "-c"]

# List available tasks.
default:
    @just --list

# Build Fastpotify.
build:
    nix build --no-update-lock-file .#fastpotify

# Check the flake.
check:
    nix flake check --no-update-lock-file

# Format Nix files.
fmt:
    nix fmt

# Update Fastpotify to the latest stable version, validate, commit, and push.
release: _require-clean
    #!/usr/bin/env bash
    set -euo pipefail
    old=$(nix eval --raw --no-update-lock-file .#fastpotify.version)
    # Use nix-update from this flake's pinned nixpkgs; it updates both source and Cargo hashes.
    nix run --no-update-lock-file --inputs-from . nixpkgs#nix-update -- --flake fastpotify --version=stable
    new=$(nix eval --raw --no-update-lock-file .#fastpotify.version)
    newer=$(OLD_VERSION="$old" NEW_VERSION="$new" nix eval --impure --expr \
        'builtins.compareVersions (builtins.getEnv "NEW_VERSION") (builtins.getEnv "OLD_VERSION")')
    if [[ "$newer" != 1 ]]; then
        echo "No newer Fastpotify version available (current: $old, found: $new)." >&2
        exit 1
    fi
    just check
    nix build --no-link --no-update-lock-file .#fastpotify
    git add -- package.nix
    git commit -m "fastpotify: $old -> $new" -- package.nix
    git push

# Update flake inputs, validate, commit with revision details, and push.
update: _require-clean
    #!/usr/bin/env bash
    set -euo pipefail
    old=$(jq -er '.nodes.nixpkgs.locked.rev' flake.lock)
    nix flake update
    if git diff --quiet -- flake.lock; then
        echo "No flake input updates available." >&2
        exit 1
    fi
    new=$(jq -er '.nodes.nixpkgs.locked.rev' flake.lock)
    just check
    nix build --no-link --no-update-lock-file .#fastpotify
    git add -- flake.lock
    git commit -m "flake: update nixpkgs ${old:0:7} -> ${new:0:7}" -- flake.lock
    git push

# Publishing must not include unrelated changes or run on a detached/untracked branch.
[private]
_require-clean:
    #!/usr/bin/env bash
    set -euo pipefail
    if [[ -n "$(git status --porcelain)" ]]; then
        echo "Working tree is not clean. Commit or stash changes (including untracked files) first." >&2
        exit 1
    fi
    git symbolic-ref --quiet HEAD >/dev/null || {
        echo "Check out a branch before publishing." >&2
        exit 1
    }
    git rev-parse --abbrev-ref --symbolic-full-name '@{upstream}' >/dev/null 2>&1 || {
        echo "Configure an upstream first: git push --set-upstream origin HEAD" >&2
        exit 1
    }
