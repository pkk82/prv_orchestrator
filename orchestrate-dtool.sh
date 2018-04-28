#!/usr/bin/env bash
# copy dtool to pf
dtoolDir=$pfDir/dtool
makeDir $dtoolDir

if [ `askYN "Configure dtool" "n"` == "y" ]; then

  unzipFamily dtool

  latest=`ls -d $dtoolDir/dtool-* | sort | tail -n 1 2>/dev/null`
  echo "export DTOOL_HOME=$latest" | sed "s|$pfDir|\$PF_DIR|" >> $varFile
  echo "export PATH=\$DTOOL_HOME/bin:\$PATH" >> $varFile

fi





