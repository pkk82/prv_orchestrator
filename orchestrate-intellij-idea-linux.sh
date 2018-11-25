#!/usr/bin/env bash

if [[ "$system" == "linux" ]]; then

  untarFamily intellij-idea "" "sed 's/ideaIU-/intellij-idea-/g'"

fi
