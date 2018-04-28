#!/usr/bin/env bash

unzipFamily dtool

latest=`ls -d $dtoolDir/dtool-* | sort | tail -n 1 2>/dev/null`
echo "export DTOOL_HOME=$latest" | sed "s|$pfDir|\$PF_DIR|" >> $varFile
echo "export PATH=\$DTOOL_HOME:\$PATH" >> $varFile





