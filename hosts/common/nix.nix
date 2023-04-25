{ config, pkgs, lib, inputs, ... }:
let

  emptyFlakeRegistry = builtins.toFile "empty-flake-registry.json" (builtins.toJSON {
    flakes = [ ];
    version = 2;
  });

in
{

  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes
      flake-registry = ${emptyFlakeRegistry}
    '';
    registry.nixpkgs.flake = inputs.nixpkgs;
    nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
  };

}
