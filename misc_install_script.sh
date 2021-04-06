#!/bin/bash

# install required brew packages
brew install coreutils findutils gawk gnu-tar gnu-sed gnutls gnu-indent gnu-getopt git git-gui grep kubernetes-cli argoproj/tap/kubectl-argo-rollouts neovim nvm ssh-copy-id tmux watchman wget z zsh zsh-completions fzf ripgrep gnupg yubikey-personalization hopenpgp-tools ykman pinentry-mac

$(brew --prefix)/opt/fzf/install

brew cask install font-fira-code
brew install --cask gpg-suite

#brew cask install alacritty

# install tmuxinator
#sudo gem install tmuxinator

# install node
nvm install --lts

# install powerline-fonts
cp ./fonts2/* ~/Library/Fonts
