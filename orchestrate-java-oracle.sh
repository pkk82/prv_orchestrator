#!/usr/bin/env bash

verify java \
  "awk -F- '{print \$(NF-1)}' | sed 's/^1\.//g' | sed 's/^/\"/g' | sed 's/$/\"/g'" \
  "bin/java -version 2>&1 | grep -i 'version' | awk '{print \$3}' | sed 's/\+/u/g' | sed 's/1\.//g' | sed 's/\.0//g' | sed 's/_/u/g'" \
  "version"

verify java \
  "awk -F- '{print \$NF}'" \
  "bin/java -version 2>&1 | (grep -i '64-Bit' || echo 'i586') | sed s/.*64-Bit.*/x64/g" \
  "platform"

createVariables java java \
  "awk -F- '{print \$(NF-1)}' | sed 's/1\.//g' | cut -du -f1 | cut -d. -f1" \
  "awk -F- '{print \$NF}' | sed 's/i586/x32/g'"
