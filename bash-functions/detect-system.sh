#!/usr/bin/env bash

function detect-system {
  local osname=`uname`
  if [[ "$USERPROFILE" != "" ]]; then
    system="win"
  elif [[ "$osname" == "Linux" ]]; then
    system="linux"
  elif [[ "$osname" == "Darwin" ]]; then
    system="mac"
  fi
  echo $system
}
