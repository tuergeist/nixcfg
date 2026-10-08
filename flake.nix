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
    llm-agents = {
      url = "github:numtide/llm-agents.nix";
    };
  };

  outputs = inputs@{ self, ... }:
    let

      inherit (inputs.nixpkgs.lib) nixosSystem;
      inherit (inputs.flake-utils.lib) eachDefaultSystem;

      # agent-deck's Go test TestStorageTwoCLIProcesses spawns CLI
      # subprocesses and hangs/fails inside the Nix build sandbox.
      # Skip the check phase so the package builds.
      llmAgentsFixup = final: prev: {
        llm-agents = prev.llm-agents // {
          agent-deck = prev.llm-agents.agent-deck.overrideAttrs (_: {
            doCheck = false;
          });
        };
      };
    in
    {
      overlays.default = import ./pkgs;

      nixosConfigurations.nutella = nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./nutella
          { nixpkgs.overlays = [ self.overlays.default inputs.llm-agents.overlays.shared-nixpkgs llmAgentsFixup ]; }
        ];
      };

      nixosConfigurations.nix1 = nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./nix1
          { nixpkgs.overlays = [ inputs.llm-agents.overlays.shared-nixpkgs llmAgentsFixup ]; }
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
