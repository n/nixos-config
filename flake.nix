{
  description = "Nick's Nix";

  inputs = {
    # Temporary pin before GDM 50.0; see NixOS/nixpkgs#523332.
    nixpkgs.url = "github:NixOS/nixpkgs?rev=d233902339c02a9c334e7e593de68855ad26c4cb";

    impermanence.url = "github:nix-community/impermanence";
    impermanence.inputs.nixpkgs.follows = "";
    impermanence.inputs.home-manager.follows = "";

    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    lanzaboote.url = "github:nix-community/lanzaboote/v1.0.0";
    lanzaboote.inputs.nixpkgs.follows = "nixpkgs";

    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";

    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    niri.url = "github:niri-wm/niri/f9f43d826ab4014a7c302be28d7da33e12f5be37";
    niri.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    { nixpkgs, ... }@inputs:
    let
      forAllSystems = nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "aarch64-darwin"
      ];

      homeManagerConfig = hostname: {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.extraSpecialArgs = { inherit hostname inputs; };
        home-manager.sharedModules = [ inputs.nix-index-database.homeModules.nix-index ];
        home-manager.users.nick = import ./users/nick;
      };

      mkDarwin =
        hostname:
        inputs.nix-darwin.lib.darwinSystem {
          specialArgs = { inherit hostname; };
          modules = [
            ./hosts/darwin-common
            inputs.nix-index-database.darwinModules.nix-index
            inputs.home-manager.darwinModules.home-manager
            {
              users.users.nick.home = "/Users/nick";
              system.primaryUser = "nick";
            }
            (homeManagerConfig hostname)
          ];
        };

      commonNixosModules = hostname: [
        inputs.nix-index-database.nixosModules.nix-index
        inputs.home-manager.nixosModules.home-manager
        inputs.lanzaboote.nixosModules.lanzaboote
        inputs.impermanence.nixosModules.impermanence
        ./hosts/nixos-common
        (homeManagerConfig hostname)
      ];
    in
    {
      darwinConfigurations = {
        mbp = mkDarwin "mbp";
        mini = mkDarwin "mini";
      };

      nixosConfigurations = {
        home = nixpkgs.lib.nixosSystem {
          modules = [ ./hosts/home ] ++ (commonNixosModules "home");
        };

        north = nixpkgs.lib.nixosSystem {
          modules = [
            { nixpkgs.overlays = [ inputs.niri.overlays.default ]; }
            ./hosts/north
          ]
          ++ (commonNixosModules "north");
        };
      };
      formatter = forAllSystems (
        system:
        (inputs.treefmt-nix.lib.evalModule nixpkgs.legacyPackages.${system} ./treefmt.nix)
        .config.build.wrapper
      );

      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell {
            name = "nix";
            buildInputs = with pkgs; [
              nixd
              nixfmt
              # Allow running `make` at the root of the repo from any dir in the devShell.
              (pkgs.writeShellScriptBin "make" ''
                ${pkgs.gnumake}/bin/make -C "$(${pkgs.git}/bin/git rev-parse --show-toplevel)" "$@"
              '')
            ];
          };
        }
      );
    };
}
