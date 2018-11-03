#!/usr/bin/env bash

function create-gradle-submodule {


  if [[ "$1" == ""  || "$2" == "" ]]; then
    echo "Use create-gradle-submodule <module name> [java|kotlin]"
  else
    submodule=$1
    mkdir -p $submodule

    if `grep -q "include" settings.gradle`; then
      echo ",'$submodule'" >> settings.gradle
    else
      echo "include '$submodule'" >> settings.gradle
    fi

    cd $submodule
    create-package-in-module $2
    cd ..

  fi
}
