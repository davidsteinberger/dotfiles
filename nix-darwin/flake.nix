{
  description = "Davids Darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mac-app-util.url = "github:hraban/mac-app-util";
  };

  outputs = inputs @ {
    self,
    nix-darwin,
    nixpkgs,
    home-manager,
    mac-app-util,
  }: let
    system = "aarch64-darwin";
    pkgs = nixpkgs.legacyPackages.${system};

    configuration = {
      pkgs,
      config,
      ...
    }: {
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages = with pkgs; [
        gnupg
        # keepassxc
        # obsidian
        # kitty
      ];

      # Auto upgrade nix package and the daemon service.
      services.nix-daemon.enable = true;
      # nix.package = pkgs.nix;

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Create /etc/zshrc that loads the nix-darwin environment.
      programs.zsh.enable = true; # default shell on catalina
      programs.zsh.promptInit = "";
      programs.zsh.enableGlobalCompInit = false;
      # programs.fish.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 5;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "${system}";
      nixpkgs.config.allowUnfree = true;

      ### custom
      security.pam.enableSudoTouchIdAuth = true;
      # https://write.rog.gr/writing/using-touchid-with-tmux/#creating-a-etcpamdsudo_local-file-using-nix-darwin
      environment = {
        etc."pam.d/sudo_local".text = ''
          # Managed by Nix Darwin
          auth       optional       ${pkgs.pam-reattach}/lib/pam/pam_reattach.so ignore_ssh
          auth       sufficient     pam_tid.so
        '';
      };
      system.defaults = {
        dock.autohide = true;
        dock.mru-spaces = false;
        finder.AppleShowAllExtensions = true;
        finder.FXPreferredViewStyle = "Nlsv";
        NSGlobalDomain = {
          AppleICUForce24HourTime = true;
          KeyRepeat = 2;
          AppleKeyboardUIMode = 3;
          "com.apple.keyboard.fnState" = true;
        };
      };

      # system.activationScripts.applications.text =
      #   let
      #     env = pkgs.buildEnv {
      #       name = "system-applications";
      #       paths = config.environment.systemPackages;
      #       pathsToLink = "/Applications";
      #     };
      #   in
      #   pkgs.lib.mkForce ''
      #     # Set up applications.
      #     echo "setting up /Applications..." >&2
      #     rm -rf /Applications/Nix\ Apps
      #     mkdir -p /Applications/Nix\ Apps
      #     find ${env}/Applications -maxdepth 1 -type l -exec readlink '{}' + |
      #     while read src; do
      #       app_name=$(basename "$src")
      #         echo "copying $src" >&2
      #         ${pkgs.mkalias}/bin/mkalias "$src" "/Applications/Nix Apps/$app_name"
      #         done
      #   '';

      # Homebrew needs to be installed on its own!
      homebrew = {
        enable = true;
        casks = [
          "wezterm"
          "nikitabobko/tap/aerospace"
          "db-browser-for-sqlite"
          "kitty"
          "keepassxc"
          "obsidian"
          "ghostty"
        ];
        taps = [
          "leoafarias/fvm"
        ];
        brews = [
          # "git"
          "mas"
          "syncthing"
          "openssl"
          "readline"
          "sqlite3"
          "xz"
          "zlib"
          "tcl-tk"
          "fvm"
          "mysql"
        ];
        masApps = {
          Yubico = 1497506650;
          Bitwarden = 1352778147;
          Spotify = 324684580;
        };
        onActivation = {
          cleanup = "zap";
          autoUpdate = true;
        };
      };
    };
  in {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#david
    darwinConfigurations."david" = nix-darwin.lib.darwinSystem {
      modules = [
        configuration
        mac-app-util.darwinModules.default
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
        mac-app-util.darwinModules.default
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
