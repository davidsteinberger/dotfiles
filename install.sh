#!/usr/bin/env bash

# install oh-my-zsh
# rm -rf ~/.zshrc ~/.oh-my-zsh
# sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
# rm ~/.zshrc
# first, run this from an interactive zsh terminal session:
rm -rf ${ZDOTDIR:-~}/.antidote
git clone --depth=1 https://github.com/mattmc3/antidote.git ${ZDOTDIR:-~}/.antidote

# install powerlevel10k
# git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

stow zsh
stow git
stow tmux
stow alacritty
stow karabiner
stow lvim
stow LazyVim
stow kitty
stow wezterm

stow -t /Applications Applications

# install tmux plugin manager
rm -rf ~/.tmux/plugins
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
echo "Start tmux with 'tmux', then run the command 'tmux source ~/.tmux.conf'"

echo "Run ./install_packages.sh"
