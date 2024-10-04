{
  description = "Example Darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, home-manager }:
    let
      system = "aarch64-darwin";
      pkgs = nixpkgs.legacyPackages.${system};

      configuration = { pkgs, ... }: {
        # List packages installed in system profile. To search by name, run:
        # $ nix-env -qaP | grep wget
        environment.systemPackages = with pkgs; [ ];

        # Auto upgrade nix package and the daemon service.
        services.nix-daemon.enable = true;
        # nix.package = pkgs.nix;

        # Necessary for using flakes on this system.
        nix.settings.experimental-features = "nix-command flakes";

        # Create /etc/zshrc that loads the nix-darwin environment.
        programs.zsh.enable = true; # default shell on catalina
        # programs.fish.enable = true;

        # Set Git commit hash for darwin-version.
        system.configurationRevision = self.rev or self.dirtyRev or null;

        # Used for backwards compatibility, please read the changelog before changing.
        # $ darwin-rebuild changelog
        system.stateVersion = 5;

        # The platform the configuration will be used on.
        nixpkgs.hostPlatform = "${system}";

        ### custom
        security.pam.enableSudoTouchIdAuth = true;
        system.defaults = {
          dock.autohide = true;
          dock.mru-spaces = false;
          finder.AppleShowAllExtensions = true;
          finder.FXPreferredViewStyle = "Nlsv";
        };

        # Homebrew needs to be installed on its own!
        homebrew.enable = true;
        homebrew.casks = [
          "wezterm"
          "nikitabobko/tap/aerospace"
        ];
        homebrew.brews = [
          "argocd"
        ];
      };
    in
    {
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#david
      darwinConfigurations."david" = nix-darwin.lib.darwinSystem {
        modules = [
          configuration
          home-manager.darwinModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users."david" = import ./home.nix;
            };
            users.users."david".home = "/Users/david";
          }
        ];
      };
      darwinConfigurations."dastein1" = nix-darwin.lib.darwinSystem {
        modules = [
          configuration
          home-manager.darwinModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users."davidsteinberger" = import ./home.nix;
            };
            users.users."davidsteinberger".home = "/Users/davidsteinberger";
          }
        ];
      };

      # Expose the package set, including overlays, for convenience.
      # darwinPackages = self.darwinConfigurations."david".pkgs;

      homeConfigurations."david" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        # Specify your home configuration modules here, for example,
        # the path to your home.nix.
        modules = [
          ./home.nix
          {
            home = {
              username = "david";
              homeDirectory = "/Users/david";
            };
          }
        ];

        # Optionally use extraSpecialArgs
        # to pass through arguments to home.nix
      };

      homeConfigurations."davidsteinberger" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        # Specify your home configuration modules here, for example,
        # the path to your home.nix.
        modules = [
          ./home.nix
          {
            home = {
              username = "davidsteinberger";
              homeDirectory = "/Users/davidsteinberger";
            };
          }
        ];

        # Optionally use extraSpecialArgs
        # to pass through arguments to home.nix
      };
    };
}
