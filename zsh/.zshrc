# zmodload zsh/zprof

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

# Path to your oh-my-zsh installation.
export ZSH=~/.oh-my-zsh

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="powerlevel10k/powerlevel10k"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# Caution: this setting can cause issues with multiline prompts (zsh 5.7.1 and newer seem to work)
# See https://github.com/ohmyzsh/ohmyzsh/issues/5765
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
# zstyle ':omz:plugins:nvm' lazy yes
zstyle ':omz:plugins:nvm' autoload true
plugins=(brew tmux git npm nvm macos z kubectl dotenv pass)

source $ZSH/oh-my-zsh.sh

# User configuration

fpath=(
  ~/.zfuncs
  "${fpath[@]}"
)

# improve startup time
# https://gist.github.com/ctechols/ca1035271ad134841284
autoload -Uz compinit 
if [[ -n ${ZDOTDIR}/.zcompdump(#qN.mh+24) ]]; then
	compinit;
else
	compinit -C;
fi;

autoload -Uz fp ll kp ks tmuxify

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
#alias ls='ls -GFh'
# Same as above, but in long listing format
#alias ll='ls -GFhl'
#alias yarn="nocorrect yarn"
alias tm="tmux new -A -s $(whoami)"
alias sp=". $HOME/dotfiles/set_proxy.sh \$1"
alias up="source $HOME/dotfiles/set_proxy.sh off"
alias ga="git add ."
alias gc="git commit -m ${1}"
alias gd="git diff"
alias gdt="git difftool"
alias gmt="git mergetool"
alias gp="git push ${1} ${2}"
alias gco="git checkout ${1} ${2}"
alias gpl="git pull ${1} ${2}"
alias grb="git rebase ${1} ${2}"
alias gs="git status"
alias la="ls -al"
alias lf="ls -al | grep ${1}"
alias ls="ls -Gl"
alias vv="$EDITOR ~/.vimrc"
alias zx="source ~/.zshrc"
alias zz="$EDITOR ~/.zshrc"
alias kr="defaults write -g ApplePressAndHoldEnabled -bool false"
alias knr="defaults write -g ApplePressAndHoldEnabled -bool true"
alias switch-keys="gpg-connect-agent \"scd serialno\" \"learn --force\" /bye"
alias flutter="fvm flutter"
alias pw="pass show -c"
alias pwo="pass otp show -c"

alias ibrew='arch -x86_64 /usr/local/bin/brew'

# gpg
export KEYID=0x7EF2450C17A54023
export GPG_TTY="$(tty)"
export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
gpgconf --launch gpg-agent

function secret {  # list preferred id last
  output="$(dirname $(realpath ${1}))/$(basename ${1}).$(date +%F).enc"
  gpg --encrypt --armor \
    --output ${output} \
    -r ${KEYID} \
    -r mail.steinberger@gmail.com \
    "${1}" && echo "${1} -> ${output}" }

function reveal {
  output=$(echo "${1}" | rev | cut -c16- | rev)
  gpg --decrypt --output ${output} "${1}" \
    && echo "${1} -> ${output}" }

# nvim
alias nvim-lazy="NVIM_APPNAME=LazyVim nvim"
alias nvim-kick="NVIM_APPNAME=kickstart nvim"
alias nvim-chad="NVIM_APPNAME=NvChad nvim"
alias nvim-astro="NVIM_APPNAME=AstroNvim nvim"
export NVIM_APPNAME=LazyVim

function nvims() {
  items=("default" "kickstart" "LazyVim" "NvChad" "AstroNvim")
  config=$(printf "%s\n" "${items[@]}" | fzf --prompt=" Neovim Config  " --height=~50% --layout=reverse --border --exit-0)
  if [[ -z $config ]]; then
    echo "Nothing selected"
    return 0
  elif [[ $config == "default" ]]; then
    config=""
  fi
  NVIM_APPNAME=$config nvim $@
}

# lazygit
export XDG_CONFIG_HOME="$HOME/.config"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

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

export GOPATH=$HOME/go
export GOROOT="/usr/local/go"
export GOBIN="$GOPATH/bin"
export PATH="$PATH:$GOROOT/bin:$GOPATH/bin"

export PATH="$PATH":"$HOME/.pub-cache/bin"

export PATH="/opt/homebrew/opt/openssl@1.1/bin:$PATH"
export PATH="/opt/homebrew/opt/openjdk@11/bin:$PATH"

# zprof
