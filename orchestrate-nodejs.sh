#!/usr/bin/env bash


nodejsDir=$pfDir/nodejs

os=`echo $osname | awk '{print tolower($0)}'`

untarFamily nodejs "sed 's|node-v|nodejs-|g' | sed 's|-$os-x64||g'"
unzipFamily nodejs "sed 's|node-v|nodejs-|g' | sed 's|-$os-x64||g'"

if [ "$os" == "win" ]; then
  prefix=""
else
  prefix="bin/"
fi

verify nodejs "${prefix}node --version | sed 's|v||g'"
createVariables2 nodejs nodejs

