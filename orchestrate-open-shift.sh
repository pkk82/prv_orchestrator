#!/usr/bin/env bash

untarFamily open-shift
createVariables open-shift oc "awk -F- '{print \$NF}' | cut -d. -f1"
