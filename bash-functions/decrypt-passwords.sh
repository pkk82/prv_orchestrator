#!/usr/bin/env bash

function decrypt-passwords {
  while read line || [[ "$line" ]]; do
    varName=`echo "$line" | cut -d= -f1`
    decryptedValue=`echo "$line" | \
      sed 's/^.*_ENC=//g' | \
      tr ' ' '\n' | \
      openssl enc -base64 -d | \
      openssl rsautl -inkey ~/.ssh/id_rsa -decrypt`
    exportString="export $(echo ${varName} | sed 's/_ENC//g')=$decryptedValue"
    eval "${exportString}"
  done < ~/.passwords
}
