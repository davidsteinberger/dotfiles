#!/bin/zsh

fpath=(
  ~/.zfuncs
  ~/.zcompletions
  "${fpath[@]}"
)
autoload bw

bw get password f0181d3b-6d36-4790-8669-b32e00f4137d
