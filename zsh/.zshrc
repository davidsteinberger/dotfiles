# zmodload zsh/zprof

fpath=(
  ~/.zfuncs
  ~/.zcompletions
  "${fpath[@]}"
)

# general settings
## emacs style keybindings
bindkey -e
bindkey \^U backward-kill-line
bindkey \^K kill-line
## shift tab navigation in menu
bindkey '^[[Z' reverse-menu-complete
## C-x C-e to edit command line in editor
autoload -z edit-command-line
zle -N edit-command-line
bindkey "^X^E" edit-command-line

unsetopt BEEP
setopt AUTO_CD
setopt GLOB_DOTS
setopt NOMATCH
setopt MENU_COMPLETE
setopt EXTENDED_GLOB
setopt INTERACTIVE_COMMENTS
setopt APPEND_HISTORY

# setopt HIST_VERIFY               # Don't execute immediately upon history expansion.
HISTFILE="${ZDOTDIR:-$HOME}/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt BANG_HIST                 # Treat the '!' character specially during expansion.
setopt EXTENDED_HISTORY          # Write the history file in the ":start:elapsed;command" format.
# setopt INC_APPEND_HISTORY        # Write to the history file immediately, not when the shell exits.
# setopt SHARE_HISTORY             # Share history between all sessions.
setopt HIST_EXPIRE_DUPS_FIRST    # Expire duplicate entries first when trimming history.
setopt HIST_IGNORE_DUPS          # Don't record an entry that was just recorded again.
setopt HIST_IGNORE_ALL_DUPS      # Delete old recorded entry if new entry is a duplicate.
setopt HIST_FIND_NO_DUPS         # Do not display a line previously found.
setopt HIST_IGNORE_SPACE         # Don't record an entry starting with a space.
setopt HIST_SAVE_NO_DUPS         # Don't write duplicate entries in the history file.
setopt HIST_REDUCE_BLANKS        # Remove superfluous blanks before recording

# antidote (now handled by nix)
# zstyle ':antidote:bundle' use-friendly-names 'yes'
# source ${ZDOTDIR:-~}/.antidote/antidote.zsh
# antidote load ${ZDOTDIR:-~}/.zsh_plugins.txt

## https://getantidote.github.io/completions
autoload -Uz zrecompile
autoload -Uz compinit
ZSH_COMPDUMP=${ZSH_COMPDUMP:-${ZDOTDIR:-~}/.zcompdump}

# cache .zcompdump for about a day
if [[ ! -e "$ZSH_COMPDUMP" || -n "$ZSH_COMPDUMP"(#qN.mh+24) ]]; then
  compinit -i -d $ZSH_COMPDUMP 
  touch $ZSH_COMPDUMP
  zrecompile -q -p -M $ZSH_COMPDUMP
else
  compinit -C -d $ZSH_COMPDUMP
fi

autoload -Uz init aws-azure-auth fp kp ks ts tn tk update_completions secret reveal nvims ff za

zstyle ':completion:*' menu yes select
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'

export CARAPACE_BRIDGES='zsh,fish,bash,inshellisense' # optional
zstyle ':completion:*' format $'\e[2;37mCompleting %d\e[m'
zstyle ':completion:*:git:*' group-order 'main commands' 'alias commands' 'external commands'
source <(carapace _carapace)

# aliases
source ${ZDOTDIR:-~}/.zaliases.zsh

# gpg
export KEYID=0x7EF2450C17A54023
export GPG_TTY="$(tty)"
export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
gpgconf --launch gpg-agent

# fzf
if [[ -f ~/.fzf.zsh ]]; then
  source ~/.fzf.zsh
else
  source <(fzf --zsh)
  fzf --zsh > ~/.fzf.zsh
fi
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# pnpm
export PNPM_HOME="${HOME}/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

eval "$(starship init zsh)"

# fnm
eval "$(fnm env --use-on-cd)"

# opam
[[ ! -r ~/.opam/opam-init/init.zsh ]] || source ~/.opam/opam-init/init.zsh  > /dev/null 2> /dev/null

# go
GOPATH="$(go env GOPATH)"
export PATH="$GOPATH/bin:$PATH"

zsh-defer source ${ZDOTDIR:-~}/.zdefer.zsh

source ${ZDOTDIR:-~}/.zlocal.zsh

# zoxide
eval "$(zoxide init zsh)"

# atuin
eval "$(atuin init zsh --disable-up-arrow)"

# zprof
