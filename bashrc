#
if [ "$UID" = "0" ]
then TERMINUS="#"
else TERMINUS="%"
fi
#
# Define some colors first:
gray='\e[0;30m'
GRAY='\e[1;30m'
red='\e[0;31m'
RED='\e[1;31m'
green='\e[0;32m'
GREEN='\e[1;32m'
yellow='\e[0;33m'
YELLOW='\e[1;33m'
blue='\e[0;34m'
BLUE='\e[1;34m'
cyan='\e[0;36m'
CYAN='\e[1;36m'
violet='\e[0;35m'
VIOLET='\e[1;35m'
white='\e[0;37m'
WHITE='\e[1;37m'
NC='\e[0m' # No Color
#

#declare -x PS1="\[\e[1;32m\]\u @ Macbook Pro \w %\[\033[0m\] "
export PS1="\u @ MBP \W % "

source ~/.common_profile

[[ -r /usr/local/etc/bash_completion.d/ag.bashcomp.sh ]] && . /usr/local/etc/bash_completion.d/ag.bashcomp.sh # Bash completion for nvm
[[ -r /usr/local/etc/bash_completion.d/brew_bash_completion.sh ]] && . /usr/local/etc/bash_completion.d/brew_bash_completion.sh # Bash completion for nvm
[[ -r /usr/local/etc/bash_completion.d/git-completion.bash ]] && . /usr/local/etc/bash_completion.d/git-completion.bash # Bash completion for Git
[[ -r /usr/local/etc/bash_completion.d/git-prompt.sh ]] && . /usr/local/etc/bash_completion.d/git-prompt.sh #
[[ -r /usr/local/etc/bash_completion.d/nvm ]] && . /usr/local/etc/bash_completion.d/nvm # Bash completion for nvm
[[ -r /usr/local/etc/bash_completion.d/tmux ]] && . /usr/local/etc/bash_completion.d/tmux #

