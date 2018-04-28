#!/usr/bin/env bash
# copy dtool to pf
dtoolDir=$pfDir/dtool
makeDir $dtoolDir

if [ `askYN "Configure dtool" "n"` == "y" ]; then

  for dtoolPath in `ls -d $cloudDir/dtool/*.zip 2>/dev/null`; do
    unzip -q $dtoolPath -d $dtoolDir
  done

fi
