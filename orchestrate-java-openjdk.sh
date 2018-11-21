#!/usr/bin/env bash

untarFamily java-openjdk "" "sed 's/-$system//g'"
verifyVersion java-openjdk "bin/java -version 2>&1 | grep 'Runtime' | awk '{print \$NF}' | sed 's/\+/u/g' | sed 's/1\.//g' | sed 's/\.0_/u/g' | sed 's/)//g' | sed 's/-b[0-9]*//g'"
createVariables2 java-openjdk openjdk "sed 's/openjdk-//g' | sed 's/u/./g' | sed 's/-x64//g'"
