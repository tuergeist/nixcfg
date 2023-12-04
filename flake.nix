{

  description = "tuergeist's nix configurations";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils = {
      url = "github:numtide/flake-utils";
    };
  };

  outputs = inputs@{ self, ... }:
    let

      inherit (inputs.nixpkgs.lib) nixosSystem;
      inherit (inputs.flake-utils.lib) eachDefaultSystem;
    in
    {


      nixosConfigurations.nutella = nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./nutella
        ];
      };

      nixosConfigurations.nix1 = nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./nix1
        ];
      };


    } // (eachDefaultSystem (system:
      let pkgs = import inputs.nixpkgs { inherit system; }; in
      {

        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [
            tig
          ];
        };
      }));   
} 
