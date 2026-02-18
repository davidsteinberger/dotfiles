{
  description = "Davids Darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
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
      security.pam.services.sudo_local = {
        enable = true;
        reattach = true;
        touchIdAuth = true;
        watchIdAuth = true;
      };
      system.defaults = {
        dock = {
          autohide = true;
          mru-spaces = false;
          expose-group-apps = true;
          appswitcher-all-displays = true;
        };
        spaces = {
          spans-displays = true;
        };
        finder = {
          AppleShowAllExtensions = true;
          FXPreferredViewStyle = "Nlsv";
        };
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
          "sf-symbols"
          "font-sf-mono"
          "font-sf-pro"
          "bruno"
          "claude"
          "opencode-desktop"
        ];
        taps = [
          "leoafarias/fvm"
          "FelixKratz/formulae"
        ];
        brews = [
          "starship"
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
          "lazydocker"
          "derailed/k9s/k9s"
          "kubectx"
          "stern"
          "neovim"
          "cormacrelf/tap/dark-notify"
          "portaudio"
          "lua"
          "sketchybar"
          {
            name = "zellij";
            args = ["HEAD"];
          }
          "clojure/tools/clojure"
          "borkdude/brew/babashka"
          "anomalyco/tap/opencode"
        ];
        masApps = {
          Yubico = 1497506650;
          Bitwarden = 1352778147;
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
            backupFileExtension = "backup";
          };
          users.users."david".home = "/Users/david";
          system = {
            primaryUser = "david";
          };
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
            backupFileExtension = "backup";
          };
          users.users."davidsteinberger".home = "/Users/davidsteinberger";
          system = {
            primaryUser = "davidsteinberger";
          };
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
