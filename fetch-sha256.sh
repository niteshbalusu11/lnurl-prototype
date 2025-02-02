#!/usr/bin/env bash

# Set versions
ZIG_VERSION="0.14.0-dev.2992+78b7a446f"
ZLS_VERSION="0.14.0-dev.366+d3d11a0"
ZLINT_VERSION="0.6.1"
# Define the platforms
declare -A PLATFORMS=(
    ["linux-x86_64"]="Linux x86_64"
    ["linux-aarch64"]="Linux ARM64"
    ["macos-x86_64"]="macOS x86_64"
    ["macos-aarch64"]="macOS ARM64"
)

echo "Fetching SHA-256 hashes for Zig version ${ZIG_VERSION}"
echo
for platform in "${!PLATFORMS[@]}"; do
    url="https://ziglang.org/builds/zig-${platform}-${ZIG_VERSION}.tar.xz"
    echo "Platform: ${PLATFORMS[$platform]}"
    echo "URL: $url"
    
    # Get the raw hash from nix-prefetch-url and convert it to base64
    raw_hash=$(nix hash convert --hash-algo sha256 --to base64 $(nix-prefetch-url "$url" 2>/dev/null))
    echo "SHA-256: sha256-${raw_hash}"
    echo
done

echo "Fetching SHA-256 hashes for ZLS version ${ZLS_VERSION}"
echo
for platform in "${!PLATFORMS[@]}"; do
    url="https://builds.zigtools.org/zls-${platform}-${ZLS_VERSION}.tar.xz"
    echo "Platform: ${PLATFORMS[$platform]}"
    echo "URL: $url"
    
    # Get the raw hash from nix-prefetch-url and convert it to base64
    raw_hash=$(nix hash convert --hash-algo sha256 --to base64 $(nix-prefetch-url "$url" 2>/dev/null))
    echo "SHA-256: sha256-${raw_hash}"
    echo
done

echo "Fetching SHA-256 hashes for zlint version ${ZLINT_VERSION}"
echo
for platform in "${!PLATFORMS[@]}"; do
    url="https://github.com/DonIsaac/zlint/releases/download/v${ZLINT_VERSION}/zlint-${platform}"
    echo "Platform: ${PLATFORMS[$platform]}"
    echo "URL: $url"
    
    raw_hash=$(nix hash convert --hash-algo sha256 --to base64 $(nix-prefetch-url "$url" 2>/dev/null))
    echo "SHA-256: sha256-${raw_hash}"
    echo
done
