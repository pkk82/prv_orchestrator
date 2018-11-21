#!/usr/bin/env bash

unzipFamily apache-ant
# to make verification work
unset ANT_HOME
verifyVersion apache-ant "bin/ant -version | awk '{print \$4}'" "if [ \$minor -lt \"10\" ] && [ ! -z \$JAVA5_x64_HOME ]; then JAVA_HOME=\$JAVA5_x64_HOME; elif [ \$minor -lt \"10\" ]; then JAVA_HOME=\$JAVA7_x64_HOME; else JAVA_HOME=\$JAVA8_x64_HOME; fi;"
createVariables2 apache-ant ant
