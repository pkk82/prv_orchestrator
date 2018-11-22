#!/usr/bin/env bash

if [[ "$system" == "win" ]]; then
  javaDir=$pfDir/java
  makeDir $javaDir
  unzipFamily java
fi
