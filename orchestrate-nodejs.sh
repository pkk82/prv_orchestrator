#!/usr/bin/env bash


nodejsDir=$pfDir/nodejs

untarFamily nodejs "sed 's|node-v|nodejs-|g' | sed 's|-[^-]*-x64$||g'"
unzipFamily nodejs "sed 's|node-v|nodejs-|g' | sed 's|-[^-]*-x64$||g'"

if [[ "$system" == "win" ]]; then
  prefix=""
else
  prefix="bin/"
fi

verifyVersion nodejs "${prefix}node --version | sed 's|v||g'"
createVariables2 nodejs nodejs
