#!/bin/bash

# install required brew packages
brew install \
	stow \
	coreutils findutils gawk gnu-tar gnu-sed gnutls gnu-indent gnu-getopt grep \
	git git-gui jesseduffield/lazygit/lazygit \
	kubernetes-cli \
	neovim nvm ssh-copy-id tmux watchman wget \
	z zsh zsh-completions \
	fzf ripgrep \
	gnupg yubikey-personalization hopenpgp-tools ykman pinentry-mac \
	pass pass-otp

$(brew --prefix)/opt/fzf/install

brew cask install font-fira-code
brew install --cask gpg-suite

brew tap homebrew/cask-fonts
brew install --cask font-fira-code-nerd-font
brew install --cask font-jetbrains-mono-nerd-font

# install node
nvm install --lts
