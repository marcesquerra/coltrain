let
  nixpkgs = (import (fetchTarball {
    url = "https://github.com/nixos/nixpkgs/tarball/a1fe662eb26ffc2a036b37c4670392ade632c413";
    sha256 = "06wjkx8b527agyrmgm0kf51pgsxjwm8330iywa8a1dmlp1jmkl3k";
  })){};
  sources = import ./nix/sources.nix;
  niv = ((import sources.niv) {}).niv;
  pkgs = import sources.nixpkgs { overlays = [] ; config = {}; };
in
  pkgs.mkShell {
    name = "coltarain-shell";
    nativeBuildInputs = [ niv pkgs.nodePackages.browser-sync ];
  }