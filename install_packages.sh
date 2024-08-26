#!/bin/bash

# install required brew packages
brew install \
  stow \
  coreutils findutils gawk gnu-tar gnu-sed gnutls gnu-indent gnu-getopt grep \
  git git-gui jesseduffield/lazygit/lazygit \
  kubernetes-cli \
  neovim fnm pyenv ssh-copy-id tmux watchman wget \
  zsh starship \
  fzf ripgrep eza \
  gnupg yubikey-personalization hopenpgp-tools ykman pinentry-mac \
  pass pass-otp

$(brew --prefix)/opt/fzf/install

brew install --cask nikitabobko/tap/aerospace
brew install --cask gpg-suite

brew tap homebrew/cask-fonts
brew install --cask font-fira-code-nerd-font
brew install --cask font-jetbrains-mono-nerd-font

# install node
fnm install --lts
