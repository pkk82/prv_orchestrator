#!/usr/bin/env bash

unzipFamily apache-ant
verify apache-ant "bin/ant -version | awk '{print \$4}'"