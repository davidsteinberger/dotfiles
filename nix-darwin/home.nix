{ config, pkgs, ... }:
let
  link = config.lib.file.mkOutOfStoreSymlink;
in
{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  # home.username = "${username}";
  # home.homeDirectory = "/Users/${config.home.username}";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.05"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    (nerdfonts.override { fonts = [ "JetBrainsMono" "FiraCode" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
    cowsay
    stow
    gitFull
    git-credential-manager
    lazygit
    delta
    neovim
    starship
    fnm
    pyenv
    fzf
    ripgrep
    eza
    pass
    passExtensions.pass-otp
    tmux
    cmake
    ninja
    coreutils
    findutils
    gawk
    gnutar
    gnused
    gnugrep
    wget
    kubectl
    ssh-copy-id
    watchman

    # lang
    go
    rustup
    opam

    # gnupg
    yubikey-personalization
    yubikey-manager
    pinentry_mac

    redis
    awscli2
    argo-rollouts

    # qmk
    qmk
    gcc-arm-embedded
    dfu-util
  ];

  fonts.fontconfig.enable = true;

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
    ".zcompletions".source = link "${config.home.homeDirectory}/dotfiles/zsh/.zcompletions";
    ".zfuncs".source = link "${config.home.homeDirectory}/dotfiles/zsh/.zfuncs";
    ".zaliases.zsh".source = link "${config.home.homeDirectory}/dotfiles/zsh/.zaliases.zsh";
    ".zdefer.zsh".source = link "${config.home.homeDirectory}/dotfiles/zsh/.zdefer.zsh";

    ".gitconfig".source = link "${config.home.homeDirectory}/dotfiles/git/.gitconfig";
    ".gitignore".source = link "${config.home.homeDirectory}/dotfiles/git/.gitignore";
    ".tmux.conf".source = link "${config.home.homeDirectory}/dotfiles/tmux/.tmux.conf";
  };

  xdg.configFile = {
    "starship.toml".source = ../starship/.config/starship.toml;
    "wezterm".source = link "${config.home.homeDirectory}/dotfiles/wezterm/.config/wezterm";
    "karabiner".source = link "${config.home.homeDirectory}/dotfiles/karabiner/.config/karabiner";
    "lvim".source = link "${config.home.homeDirectory}/dotfiles/lvim/.config/lvim";
    "lazygit".source = link "${config.home.homeDirectory}/dotfiles/lazygit/.config/lazygit";
    "LazyVim".source = link "${config.home.homeDirectory}/dotfiles/LazyVim/.config/LazyVim";
    "kitty".source = link "${config.home.homeDirectory}/dotfiles/kitty/.config/kitty";
    "warpd".source = link "${config.home.homeDirectory}/dotfiles/warpd/.config/warpd";
    "aerospace".source = link "${config.home.homeDirectory}/dotfiles/aerospace/.config/aerospace";
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/david/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    EDITOR = "nvim";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.zsh = {
    enable = true;
    shellAliases = {
      hm = "nix run home-manager/master -- switch --flake ~/dotfiles/nix-darwin";
      rebuild = "darwin-rebuild switch --flake ~/dotfiles/nix-darwin";
      update = "home-manager switch --flake ~/dotfiles/nix-darwin";
    };
    initExtra = builtins.readFile ../zsh/.zshrc;
    envExtra = builtins.readFile ../zsh/.zshenv;
    enableCompletion = false;
    # localVariables = {
    #   NIX_ZSH_FILES = builtins.toString ../zsh;
    # };
    antidote = {
      enable = true;
      plugins = [
        "ohmyzsh/ohmyzsh path:plugins/pass kind:fpath"
        "ohmyzsh/ohmyzsh path:plugins/dotenv"
        "zsh-users/zsh-autosuggestions kind:defer"
        "zap-zsh/zap-prompt"
        "zsh-users/zsh-syntax-highlighting"
        "zsh-users/zsh-completions"
        "agkozak/zsh-z"
      ];
    };
  };
}
