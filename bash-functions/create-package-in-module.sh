#!/usr/bin/env bash

function create-package-in-module {

  if [[ "$1" == "" ]]; then
    echo "Use create-package-in-module [java|kotlin] [main|test]"
  else
    if [[ "$2" == "test" ]]; then
      kindDir="test"
    else
      kindDir="main"
    fi

    if [[ "$1" == "kotlin" ]]; then
      lang="kotlin"
    else
      lang="java"
    fi


    mkdir -p src/$kindDir/$lang
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
    if [[ $clip =~ ^[0-9]+$ ]]; then
      packageName="$packageName.c$clip"
    fi

    packageDir=`echo $packageName | sed 's|\.|/|g'`
    mkdir -p src/$kindDir/$lang/$packageDir

    fileName=`echo $dir | awk -F_ '{print $NF}'`
    if [ "$kindDir" == "test" ]; then
      fileName="${fileName}Test"
    fi

    if [ "$lang" == "java" ]; then
      fileName="$fileName.java"
      echo "package $packageName;" >> src/$kindDir/$lang/$packageDir/$fileName
    else
      fileName="$fileName.kt"
      echo "package $packageName" >> src/$kindDir/$lang/$packageDir/$fileName
    fi




  fi
}
