{
  description = "Nick's Nix";

  inputs = {
    impermanence.url = "github:nix-community/impermanence";

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
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      nix-darwin,
      home-manager,
      treefmt-nix,
      impermanence,
      lanzaboote,
      nix-index-database,
      ...
    }:
    let
      homeManagerConfig = hostname: {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.extraSpecialArgs = { inherit hostname; };
        home-manager.sharedModules = [ nix-index-database.homeModules.nix-index ];
        home-manager.users.nick = import ./users/nick;
      };

      mkDarwin =
        hostname:
        nix-darwin.lib.darwinSystem {
          specialArgs = { inherit hostname; };
          modules = [
            ./hosts/darwin-common
            nix-index-database.darwinModules.nix-index
            home-manager.darwinModules.home-manager
            {
              users.users.nick.home = "/Users/nick";
              system.primaryUser = "nick";
            }
            (homeManagerConfig hostname)
          ];
        };

      commonNixosModules = hostname: [
        nix-index-database.nixosModules.nix-index
        home-manager.nixosModules.home-manager
        lanzaboote.nixosModules.lanzaboote
        impermanence.nixosModules.impermanence
        ./common/users.nix
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
          modules = [
            ./hosts/home/configuration.nix
            ./hosts/home/persist.nix
          ]
          ++ (commonNixosModules "home");
        };

        north = nixpkgs.lib.nixosSystem {
          modules = [
            ./hosts/north/configuration.nix
            ./hosts/north/wayland.nix
            ./hosts/north/syncthing.nix
            ./hosts/north/persist.nix
          ]
          ++ (commonNixosModules "north");
        };
      };
    }
    // flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        treefmtEval = treefmt-nix.lib.evalModule pkgs ./treefmt.nix;
      in
      {
        # Note: Using flake-utils.lib.eachDefaultSystem with // creates outputs like:
        # { x86_64-linux = { formatter = ..., devShells = ... } }
        # While the standard flake schema would be:
        # { formatter = { x86_64-linux = ... }, devShells = { x86_64-linux = ... } }
        # Nix commands are tolerant of both structures, so this works fine for most purposes.
        formatter = treefmtEval.config.build.wrapper;
        devShells = {
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
        };
      }
    );
}
