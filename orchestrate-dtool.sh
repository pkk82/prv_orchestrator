#!/usr/bin/env bash

files=(dtool.sh dtool.bat dtool.command)

# find key
function findKey {
  value=""
  for dtool in `ls -d $pfDir/dtool/dtool-* 2>/dev/null`; do
    for file in ${files[*]}; do
      launcher="$dtool/$file"
      if grep -q "$1=" "$launcher"; then
        if ! grep -q "$1=\.\.\." "$launcher"; then
          value=`cat $launcher | grep $1 | awk '{print $1}' | cut -d= -f2`
          break 2
        fi
      fi
    done
  done
  echo "$value"
}

customerSecretKey="\-Ddtool.bitbucket.customer.secret"
customerSecret=`findKey $customerSecretKey`

customerKeyKey="\-Ddtool.bitbucket.customer.key"
customerKey=`findKey $customerKeyKey`


# create new
unzipFamily dtool

latest=`ls -d $pfDir/dtool/dtool-* | sort | tail -n 1 2>/dev/null`
echo "export DTOOL_HOME=$latest" | sed "s|$pfDir|\$PF_DIR|" >> $varFile
echo "export PATH=\$DTOOL_HOME:\$PATH" >> $varFile

for dtool in `ls -d $pfDir/dtool/dtool-* 2>/dev/null`; do
  for file in ${files[*]}; do
    launcher="$dtool/$file"
    if grep -q "$customerSecretKey=\.\.\." "$launcher"; then
      if [[ "$customerKey" == "" ]]; then
        customerKey=`askPassword "Enter bitbucket dtool key"`
        printf "\n"
      fi
       if [[ "$customerKey" != "" ]]; then
        sed -i $sedBackupSuffix "s/$customerKeyKey=\.\.\./$customerKeyKey=$customerKey/g" "$launcher"
      fi
      if [[ "$customerSecret" == "" ]]; then
        customerSecret=`askPassword "Enter bitbucket dtool secret"`
        printf "\n"
      fi
      if [[ "$customerSecret" != "" ]]; then
        sed -i $sedBackupSuffix "s/$customerSecretKey=\.\.\./$customerSecretKey=$customerSecret/g" "$launcher"
      fi
    fi
  done
done
