#!/usr/bin/env bash

function calculate-group-id {

    local currentDir=`pwd`
    local dir=`dirname $currentDir`
    local groupId=''
    while [[ "$dir" != *"workspace" ]] && [[ "$dir" != "/" ]]; do
      groupId=`basename $dir`
      dir=`dirname $dir`
    done

    groupId=`echo $groupId | sed 's/\.$//g'`
    echo "$groupId"
}
