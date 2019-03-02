#!/usr/bin/env bash

untarFamily scala "sed s/.final//g"
verifyVersion scala "bin/scala -version 2>&1 | awk '{print \$5}' | sed s/.final//g"
createVariables2 scala scala
