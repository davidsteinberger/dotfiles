#!/bin/bash

if [[ "$1" == "on" ]] || [[ "$1" == "" ]]; then
  echo "setting proxy"
  export http_proxy="http://pw-emea-pitc-amsterdamz.proxy.corporate.ge.com:80"
  export HTTP_PROXY=$http_proxy
  export https_proxy="http://pw-emea-pitc-amsterdamz.proxy.corporate.ge.com:80"
  export HTTPS_PROXY=$https_proxy
  export no_proxy="localhost, 127.0.0.1, 127.227.0.1, 127.229.0.1, 10.0.5.100,github.build.ge.com"
  export NO_PROXY=$no_proxy
else
  echo "clearing proxy"
  unset http_proxy
  unset HTTPS_PROXY
  unset https_proxy
  unset HTTP_PROXY
  unset no_proxy
  unset NO_PROXY
fi
