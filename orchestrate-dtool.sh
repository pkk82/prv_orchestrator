#!/usr/bin/env bash

files=(dtool.sh dtool.bat dtool.command)
keyValue="\-Ddtool.bitbucket.customer.secret"
customerSecret=""

# find existing customer key
for dtool in `ls -d $pfDir/dtool/dtool-* 2>/dev/null`; do
  for file in ${files[*]}; do
    launcher="$dtool/$file"
    if grep -q "$keyValue=" "$launcher"; then
      if ! grep -q "$keyValue=\.\.\." "$launcher"; then
        customerSecret=`cat $launcher | grep $keyValue | awk '{print $1}' | cut -d= -f2`
        break 2
      fi
    fi
  done
done

# create new
unzipFamily dtool

latest=`ls -d $pfDir/dtool/dtool-* | sort | tail -n 1 2>/dev/null`
echo "export DTOOL_HOME=$latest" | sed "s|$pfDir|\$PF_DIR|" >> $varFile
echo "export PATH=\$DTOOL_HOME:\$PATH" >> $varFile

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
