#!/usr/bin/env bash


nodejsDir=$pfDir/nodejs

untarFamily nodejs "sed 's|node-v|nodejs-|g' | sed 's|-[^-]*-x64$||g'"
unzipFamily nodejs "sed 's|node-v|nodejs-|g' | sed 's|-[^-]*-x64$||g'"

if [ "$system" == "windows" ]; then
  prefix=""
else
  prefix="bin/"
fi

verify nodejs "${prefix}node --version | sed 's|v||g'"
createVariables2 nodejs nodejs
