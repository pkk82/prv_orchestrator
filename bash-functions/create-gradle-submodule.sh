#!/usr/bin/env bash

function create-gradle-submodule {

  if [[ detect-system == "mac" ]]; then
    sedBackupSuffix=".bak"
  else
    sedBackupSuffix=""
  fi


  if [[ "$1" == ""  || "$2" == "" ]]; then
    echo "Use create-gradle-submodule <module name> [java|kotlin]"
  else
    submodule=$1
    mkdir -p $submodule

    if `grep -q "include" settings.gradle`; then
      lastLine=`cat settings.gradle | awk 'NF{p=$0}END{print p}'`
      sed -i $sedBackupSuffix "s/$lastLine/$lastLine,\n        '$submodule'/g" settings.gradle
    else
      echo "include '$submodule'" >> settings.gradle
    fi

    cd $submodule
    create-package-in-module $2
    cd ..

  fi
}
