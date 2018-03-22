#!/usr/bin/env bash

unzipFamily apache-ant
verify apache-ant "bin/ant -version | awk '{print \$4}'" "if [ \$minor -lt \"10\" ]; then JAVA_HOME=\$JAVA7_HOME; else JAVA_HOME=\$JAVA8_HOME; fi;"
createVariables2 apache-ant ANT