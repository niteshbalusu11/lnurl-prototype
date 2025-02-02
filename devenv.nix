{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:
let
  # Define versions
  zigVersion = "0.14.0-dev.2992+78b7a446f";
  zlsVersion = "0.14.0-dev.366+d3d11a0";
  zlintVersion = "0.6.1";

  # Determine the system architecture and OS
  system = pkgs.stdenv.hostPlatform.system;

  # Define the URLs for the latest nightly Zig builds
  zigNightlyUrls = {
    "x86_64-linux" = "https://ziglang.org/builds/zig-linux-x86_64-${zigVersion}.tar.xz";
    "aarch64-linux" = "https://ziglang.org/builds/zig-linux-aarch64-${zigVersion}.tar.xz";
    "x86_64-darwin" = "https://ziglang.org/builds/zig-macos-x86_64-${zigVersion}.tar.xz";
    "aarch64-darwin" = "https://ziglang.org/builds/zig-macos-aarch64-${zigVersion}.tar.xz";
  };

  # Define the URLs for ZLS builds
  zlsUrls = {
    "x86_64-linux" = "https://builds.zigtools.org/zls-linux-x86_64-${zlsVersion}.tar.xz";
    "aarch64-linux" = "https://builds.zigtools.org/zls-linux-aarch64-${zlsVersion}.tar.xz";
    "x86_64-darwin" = "https://builds.zigtools.org/zls-macos-x86_64-${zlsVersion}.tar.xz";
    "aarch64-darwin" = "https://builds.zigtools.org/zls-macos-aarch64-${zlsVersion}.tar.xz";
  };

  zlintUrls = {
    "x86_64-linux" =
      "https://github.com/DonIsaac/zlint/releases/download/v${zlintVersion}/zlint-linux-x86_64";
    "aarch64-linux" =
      "https://github.com/DonIsaac/zlint/releases/download/v${zlintVersion}/zlint-linux-aarch64";
    "x86_64-darwin" =
      "https://github.com/DonIsaac/zlint/releases/download/v${zlintVersion}/zlint-macos-x86_64";
    "aarch64-darwin" =
      "https://github.com/DonIsaac/zlint/releases/download/v${zlintVersion}/zlint-macos-aarch64";
  };
  # Fetch the appropriate Zig binary
  zigNightly = pkgs.stdenv.mkDerivation rec {
    name = "zig-nightly";
    src = pkgs.fetchurl {
      url = zigNightlyUrls.${system};
      sha256 =
        {
          "x86_64-linux" = "sha256-hzqKAAOaOd3e0oZu3FXscYqIHW6oTXdmz3WUk5TxEj8=";
          "aarch64-linux" = "sha256-2PvMyM2zTdjrzpVKIdu5mzDnX/2XJ+3JCpko7wiI1nM=";
          "x86_64-darwin" = "sha256-kfFrwvyFuCPAAoIgN/2OFlxMdPMkEskutjRI8QYLwps=";
          "aarch64-darwin" = "sha256-qkMb25nHROirVASQKzbterzMAE1fOf8w5Vkaz3SHdmM=";
        }
        .${system};
    };
    buildInputs = [ pkgs.xz ];
    installPhase = ''
      mkdir -p $out/bin
      tar -xJf $src -C $out/bin --strip-components=1
    '';
  };

  # Build zlint from source
  zlint = pkgs.stdenv.mkDerivation rec {
    pname = "zlint";
    version = zlintVersion;
    name = "${pname}-${version}";

    src = pkgs.fetchurl {
      url = zlintUrls.${system};
      sha256 =
        {
          "x86_64-linux" = "sha256-JjgHNHg75DWcuDvElJDKbPoHJNopy1LNwTlX4X1L2RE="; # We'll get this using your script
          "aarch64-linux" = "sha256-aToZH8xb/CeL6wJxYRwHdui51PX5rwhEg+j4pXlvLYc=";
          "x86_64-darwin" = "sha256-tzcO3VC+Dkqs20egLLgHfyR76nRBNQUq6ibEzbnHwNc=";
          "aarch64-darwin" = "sha256-YowLqF7wb2DJ8McjRoh5yqPOju4nZ/L2iuDyJhJCl+Q=";
        }
        .${system};
    };

    dontUnpack = true;

    installPhase = ''
      mkdir -p $out/bin
      cp $src $out/bin/zlint
      chmod +x $out/bin/zlint
    '';

    meta = with lib; {
      description = "A linter for Zig";
      homepage = "https://github.com/DonIsaac/zlint";
      license = licenses.mit;
      platforms = platforms.unix;
    };
  };

  # Fetch the appropriate ZLS binary
  zlsBinary = pkgs.stdenv.mkDerivation rec {
    name = "zls";
    src = pkgs.fetchurl {
      url = zlsUrls.${system};
      sha256 =
        {
          "x86_64-linux" = "sha256-yv0mi8XMdVQTcxE96Z/bpsaXW76G8A8Rrd8GKLw1P64=";
          "aarch64-linux" = "sha256-XVTxnJlqh/GJok09KCWwDhdrw3ZtHt0S2oPu9AuL0do=";
          "x86_64-darwin" = "sha256-xI7cIlNIthq1Gpu5uHDPe20Whf/zV1NBB67rJyhaiiY=";
          "aarch64-darwin" = "sha256-ucKDwLlCiMcq41PvcM/7Fgvw/26zY2jrk4NBFqrBH8k=";
        }
        .${system};
    };
    buildInputs = [ pkgs.xz ];
    unpackPhase = ''
      mkdir -p source
      cd source
      tar xf $src
    '';
    installPhase = ''
      mkdir -p $out/bin
      cp zls $out/bin/
      chmod +x $out/bin/zls
    '';
  };
in
{
  # https://devenv.sh/basics/
  env.GREET = "devenv";

  # https://devenv.sh/packages/
  packages = [
    pkgs.git
    zigNightly
    zlsBinary
    zlint
  ];

  # https://devenv.sh/scripts/
  scripts.hello.exec = ''
    echo hello from $GREET
  '';

  enterShell = ''
      hello
      git --version
      zig version
      zls --version
    zlint --version
  '';

  # https://devenv.sh/tests/
  enterTest = ''
      echo "Running tests"
      git --version | grep --color=auto "${pkgs.git.version}"
      zig version
      zls --version
    zlint --version
  '';
}
