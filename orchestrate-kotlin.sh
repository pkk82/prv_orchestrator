#!/usr/bin/env bash

unzipFamily kotlin "" "sed 's/kotlin-compiler-/kotlin-/g'"
verifyVersion kotlin "bin/kotlin -version 2>&1 | grep -i version | awk '{print \$3}' | awk -F- '{print \$1}'"
createVariables2 kotlin kotlin


