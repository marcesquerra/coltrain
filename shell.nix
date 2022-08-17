let
  nixpkgs = (import (fetchTarball {
    url = "https://github.com/nixos/nixpkgs/tarball/a1fe662eb26ffc2a036b37c4670392ade632c413";
    sha256 = "06wjkx8b527agyrmgm0kf51pgsxjwm8330iywa8a1dmlp1jmkl3k";
  })){};
  sources = import ./nix/sources.nix;
  niv = ((import sources.niv) {}).niv;
  moz-overlay = ((import sources.nixpkgs-mozilla) ) ;
  pkgs = import sources.nixpkgs { overlays = [ moz-overlay ] ; config = {}; };
  rustChannel = (pkgs.rustChannelOf { date = "2022-08-11"; channel = "stable"; });
  rust = rustChannel.rust;
  rust-src = rustChannel.rust-src;
  rustPlatform = pkgs.makeRustPlatform{
      cargo = rust;
      rustc = rust;
    };
  getFromCargo = {src, cargoSha256, nativeBuildInputs ? [], cargoBuildFlags ? []} :
    let
      lib = pkgs.lib;
      asName = candidates :
        let
          ts = e: if (builtins.isAttrs e) && (builtins.hasAttr "name" e) && e.name != null then e.name else toString e;
          stringCandidates = map ts candidates;
          wholeString = lib.concatStrings stringCandidates;
        in
          builtins.hashString "sha256" wholeString;
    in
      rustPlatform.buildRustPackage rec {
        inherit src cargoSha256 nativeBuildInputs cargoBuildFlags;
        pname = "cargo-${asName [src]}";
        version = "N/A";
        doCheck = false;
      };
  rust-analayzer = getFromCargo {
    src = sources.rust-analyzer;
    cargoSha256 = "sha256-brt02yLr5kUgTjgpugewuPeiYdFwxMngZCmhan3CgEM=";
  };
in
  pkgs.mkShell {
    name = "coltarain-shell";
    # nativeBuildInputs = [ niv pkgs.nodePackages.browser-sync ];
    nativeBuildInputs = with pkgs;[ niv rust rust-analayzer libinput udev pkg-config ];
    shellHook = ''
      export RUST_SRC_PATH="${rust-src}/lib/rustlib/src/rust/library"
    '';
  }
