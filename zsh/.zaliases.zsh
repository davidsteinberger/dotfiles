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
alias zx="source ~/.zshrc"
alias zz="$EDITOR ~/.zshrc"
alias kr="defaults write -g ApplePressAndHoldEnabled -bool false"
alias knr="defaults write -g ApplePressAndHoldEnabled -bool true"
alias switch-keys="gpg-connect-agent \"scd serialno\" \"learn --force\" /bye"
alias flutter="fvm flutter"
## eza
alias ls='eza --color=always --group-directories-first --icons=always'
alias ll='eza -la --icons=always --octal-permissions --group-directories-first'
alias l='eza -bGF --header --git --color=always --group-directories-first --icons=always'
alias llm='eza -lbGd --header --git --sort=modified --color=always --group-directories-first --icons=always' 
alias la='eza --long --all --group --group-directories-first'
alias lx='eza -lbhHigUmuSa@ --time-style=long-iso --git --color-scale --color=always --group-directories-first --icons=always'

alias lS='eza -1 --color=always --group-directories-first --icons=always'
alias lt='eza --tree --level=2 --color=always --group-directories-first --icons=always'
alias l.="eza -a | grep -E '^\.'"
alias fzf="fzf --cycle  --multi --bind 'tab:toggle-up,btab:toggle-down'"

alias ibrew='arch -x86_64 /usr/local/bin/brew'

# nvim
alias nvim-lazy="NVIM_APPNAME=LazyVim nvim"
alias nvim-kick="NVIM_APPNAME=kickstart nvim"
alias nvim-chad="NVIM_APPNAME=NvChad nvim"
alias nvim-astro="NVIM_APPNAME=AstroNvim nvim"

alias v="nvim"
alias n="npm"
alias k="k9s"

# tmux
alias tm="tmux new -A -s $(whoami)"
