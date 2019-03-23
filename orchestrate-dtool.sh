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

bbUserDefaultKey="\-Ddtool.bitbucket.user.default"
bbUserDefaultPrevious=`findKey $bbUserDefaultKey`

gitCommitterEmailKey="\-Ddtool.git.committer.email"
gitCommitterEmailPrevious=`findKey $gitCommitterEmailKey`

bbUserDefaultSuggested=`git remote -v | grep "origin" | grep "fetch" | sed 's|^[^:]*:\([^/]*\).*$|\1|g'`
gitCommitterEmailSuggested=`git config --list | grep "user.email" | cut -d= -f2`

# $1 - file name
# $2 - key
# $3 - value
function replaceInFile {
  if [[ "$3" != "" ]]; then
    sed -i $sedBackupSuffix "s/$2=\.\.\./$2=$3/g" "$1"
  fi
}


# create new
unzipFamily dtool

latest=`ls -d $pfDir/dtool/dtool-* | sort | tail -n 1 2>/dev/null`
echo "# dtool" >> "$varFile"
echo "export DTOOL_HOME=$latest" | sed "s|$pfDir|\$PF_DIR|" >> $varFile
echo "export PATH=\$DTOOL_HOME:\$PATH" >> $varFile

bbUserDefault=""
gitCommitterEmail=""

for dtool in `ls -d $pfDir/dtool/dtool-* 2>/dev/null`; do
  for file in ${files[*]}; do
    launcher="$dtool/$file"
    if grep -q "$customerSecretKey=\.\.\." "$launcher"; then
      if [[ "$customerKey" == "" ]]; then
        customerKey=`askPassword "Enter bitbucket dtool key"`
        printf "\n"
      fi
      if [[ "$customerSecret" == "" ]]; then
        customerSecret=`askPassword "Enter bitbucket dtool secret"`
        printf "\n"
      fi

      if [[ "$bbUserDefaultPrevious" != "$bbUserDefaultSuggested" ]] && [[ "$bbUserDefaultPrevious" != "" ]]; then
        warningMessage "Found different bb user defaults: $bbUserDefaultPrevious / $bbUserDefaultSuggested"
      fi


      if [[ "$gitCommitterEmailPrevious" != "$gitCommitterEmailSuggested" ]] && [[ "$gitCommitterEmailPrevious" != "" ]]; then
        warningMessage "Found different git committer defaults: $gitCommitterEmailPrevious / $gitCommitterEmailSuggested"
      fi


      if [[ "$bbUserDefault" == "" ]]; then
        bbUserDefault=`askWithDefaults "Enter bb user" $bbUserDefaultPrevious $bbUserDefaultSuggested`
      fi

      if [[ "$gitCommitterEmail" == "" ]]; then
        gitCommitterEmail=`askWithDefaults "Enter git committer email" $gitCommitterEmailPrevious $gitCommitterEmailSuggested`
      fi

      replaceInFile "$launcher" "$customerKeyKey" "$customerKey"
      replaceInFile "$launcher" "$customerSecretKey" "$customerSecret"
      replaceInFile "$launcher" "$bbUserDefaultKey" "$bbUserDefault"
      replaceInFile "$launcher" "$gitCommitterEmailKey" "$gitCommitterEmail"


    fi
  done
done
