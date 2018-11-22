#!/usr/bin/env bash

untarFamily java-openjdk "" "sed 's/-$system//g'"

verify java-openjdk \
  "awk -F- '{print \$(NF-1)}' | sed 's/^1\.//g'" \
  "bin/java -version 2>&1 | grep 'Runtime' | awk '{print \$NF}' | sed 's/\+/u/g' | sed 's/1\.//g' | sed 's/\.0_/u/g' | sed 's/)//g' | sed 's/-b[0-9]*//g'" \
  "version"

createVariables java-openjdk openjdk \
  "awk -F- '{print \$(NF-1)}' | sed 's/1\.//g' | cut -du -f1 | cut -d. -f1" \
  "awk -F- '{print \$NF}'"
