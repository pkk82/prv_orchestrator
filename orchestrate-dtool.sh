#!/usr/bin/env bash

unzipFamily dtool

latest=`ls -d $pfDir/dtool/dtool-* | sort | tail -n 1 2>/dev/null`
echo "export DTOOL_HOME=$latest" | sed "s|$pfDir|\$PF_DIR|" >> $varFile
echo "export PATH=\$DTOOL_HOME:\$PATH" >> $varFile

files=(dtool.sh dtool.bat dtool.command)
keyValue="\-Ddtool.bitbucket.customer.secret"
customerSecret=""
for dtool in `ls -d $pfDir/dtool/dtool-* 2>/dev/null`; do
  for file in ${files[*]}; do
    launcher="$dtool/$file"
    if grep -q "$keyValue=\.\.\." "$launcher"; then
      if [[ "$customerSecret" == "" ]]; then
        customerSecret=`askPassword "Enter bitbucket dtool secret"`
      fi
      if [[ "$customerSecret" != "" ]]; then
        sed -i $sedBackupSuffix "s/$keyValue=\.\.\./$keyValue=$customerSecret/g" "$launcher"
      fi
    fi
  done
done
