# export ZDOTDIR=~/
export ZSH_CACHE_DIR=~/
export ZSH=~/

# You may need to manually set your language environment
export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

export NVIM_APPNAME=LazyVim

# lazygit
export XDG_CONFIG_HOME="$HOME/.config"

export PATH="$HOME/.local/bin:$PATH"
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
export PATH="/opt/homebrew/sbin:$PATH"
export PATH="/usr/local/sbin:$PATH"
export PATH="/usr/local/opt/gettext/bin:$PATH"
export PATH="/usr/local/opt/libpq/bin:$PATH"
export PATH="/usr/local/opt/tcl-tk/bin:$PATH"
export PATH="/usr/local/opt/libpq/bin:$PATH"
export PATH="${PATH}:${HOME}/.krew/bin"
export PATH="${HOME}/fvm/default/bin${PATH}"
export PATH="$PATH":"$HOME/.pub-cache/bin"
export PATH="/opt/homebrew/opt/openssl@1.1/bin:$PATH"

# go
export GOPATH=$HOME/go
export GOROOT="/usr/local/go"
export GOBIN="$GOPATH/bin"
export PATH="$PATH:$GOROOT/bin:$GOPATH/bin"

# rust
source "$HOME/.cargo/env"

export PATH="/opt/homebrew/opt/openjdk@11/bin:$PATH"


