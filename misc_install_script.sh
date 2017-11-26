#!/bin/bash

# install NeoBundle"
curl https://raw.githubusercontent.com/Shougo/neobundle.vim/master/bin/install.sh | sh;

# install required brew packages
brew tap homebrew/dupes
brew install cmake gawk git grep macvim reattach-to-user-namespace the_silver_searcher tmux vim neovim/neovim/neovim watchman zsh zsh-completions dos2unix zsh z pyenv rbenv
brew link gawk

# install tmuxinator
sudo gem install tmuxinator

# install neovim package
pip3 install --user neovim

# install global npm packages
# Note: make sure node is installed before (install it via nvm)!
npm install -g add-cors-to-couchdb babel-eslint bower browserify coffee-script cordova create-react-app ember-cli ember-prerender ember-template-lint eslint eslint-config-google eslint-config-standard-react eslint-plugin-html eslint-plugin-react eslint-plugin-standard eslint-rules-mapper express express-generator express-redis-cache generator-polymer-gulp generator-polymer-init-custom-build generator-px-comp grunt-cli gulp gulp-cli html-minifier htmlhint inliner instant-markdown-d jshint jspm jspm-bower-endpoint jsxhint madge mocha mocha neovim nodemon phantomjs polymer-cli requirejs rollup sloc supports-color tern tslint typescript typescript-eslint-parser typings vulcanize wdio wdio-sync web-component-tester yo

# install powerline-fonts
cd fonts && ./install.sh && cd ..
