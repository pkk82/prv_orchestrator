#!/usr/bin/env bash

function copy-node-submodule {

  if [[ detect-system == "mac" ]]; then
    sedBackupSuffix=".bak"
  else
    sedBackupSuffix=""
  fi

  if [[ "$1" == ""  || "$2" == "" ]]; then
    echo "Use create-gradle-submodule <src module name> <dest module name>"
    return 1;
  fi

  if [[ ! -d "./$1" ]]; then
    echo "$2 must be a directory in current folder"
    return 1;
  fi

  mkdir -p $2
  cp -a $1/. $2/
  rm -rf $2/node_modules
  rm -f $2/package-lock.json

  sed -i $sedBackupSuffix "s/\"name\": \".*\"/\"name\": \"$2\"/g" "$2/package.json"
  cd "$2"
}
