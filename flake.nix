{

  description = "tuergeist's nix configurations";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, ... }:
    let

      inherit (inputs.nixpkgs.lib) nixosSystem;

    in
    {


      nixosConfigurations.nutella = nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./nutella
#          ./hosts/common/users/betaboon.nix
#          ./homes/betaboon
        ];
      };


    };
} 
