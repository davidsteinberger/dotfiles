#!/bin/bash

# install NeoBundle"
curl https://raw.githubusercontent.com/Shougo/neobundle.vim/master/bin/install.sh | sh;

# install required brew packages
brew install awscli coreutils couchdb dos2unix doxygen findutils gawk gnu-tar gnu-sed gnutls gnu-indent gnu-getopt git git-gui gradle grep kubernetes-cli argoproj/tap/kubectl-argo-rollouts neovim nvm pyenv pyenv-virtualenv rbenv reattach-to-user-namespace redis sbt scala siege ssh-copy-id the_silver_searcher tmux vim watchman wget yq z zsh zsh-completions fzf ripgrep

$(brew --prefix)/opt/fzf/install

brew tap homebrew/cask-fonts

brew cask install font-fira-code

brew cask install alacritty

# install tmuxinator
sudo gem install tmuxinator

pyenv install 3.8.5

pyenv global system

# install neovim package
pip3 install pynvim

# pip install --user alacritty-colorscheme

# install node
nvm install --lts

# install global npm packages
# Note: make sure node is installed before (install it via nvm)!
yarn global add aws-azure-login create-react-app gulp gulp-cli polymer-cli tern typescript

# install powerline-fonts
cd fonts && ./install.sh && cd ..
