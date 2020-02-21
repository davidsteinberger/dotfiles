#!/bin/bash

# install NeoBundle"
curl https://raw.githubusercontent.com/Shougo/neobundle.vim/master/bin/install.sh | sh;

# install required brew packages
brew install aws-iam-authenticator awscli coreutils couchdb dos2unix doxygen findutils gawk gnu-tar gnu-sed gnutls gnu-indent gnu-getopt git gradle grep kubernetes-cli maven neovim nginx nvm pyenv pyenv-virtualenv rbenv reattach-to-user-namespace redis sbt scala siege ssh-copy-id the_silver_searcher tmux vim watchman wget yq z zsh zsh-completions fastlane

# install tmuxinator
sudo gem install tmuxinator

# install neovim package
pip3 install --user neovim

# install node
nvm install --lts

# install global npm packages
# Note: make sure node is installed before (install it via nvm)!
yarn global add create-react-app gulp gulp-cli polymer-cli tern typescript

# install powerline-fonts
cd fonts && ./install.sh && cd ..
