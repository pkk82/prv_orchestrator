#!/usr/bin/env bash

function create-package-under-source-directory {

  if [[ "$1" == "" ]]; then
    echo "Use create-package-under-source-directory [java|kotlin] [main|test]"
  else
    if [[ "$1" == "kotlin" ]]; then
      mkdir -p src/main/kotlin
      dir=`pwd`
      dir=`dirname $dir`
      packageName=''
      while [[ "$dir" != *"workspace" ]]; do
        packageName="`basename $dir`.$packageName"
        dir=`dirname $dir`
      done
      packageName=`echo $packageName | sed 's/.$//g' | sed 's/[-_]//g' | sed 's/c\.pl/pluralsight/g'`
      dir=`pwd`
      dir=`basename $dir`
      module=`echo $dir | cut -d _ -f1`
      if [[ $module =~ ^[0-9]+$ ]]; then
        packageName="$packageName.m$module"
      fi
      clip=`echo $dir | cut -d _ -f2`
            module=`echo $dir | cut -d _ -f1`
      if [[ $clip =~ ^[0-9]+$ ]]; then
        packageName="$packageName.c$clip"
      fi
      packageDir=`echo $packageName | sed 's|\.|/|g'`
      mkdir -p src/main/kotlin/$packageDir
      echo "package $packageName" >> src/main/kotlin/$packageDir/App.kt
    fi


  fi
}
