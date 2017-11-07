#!/usr/bin/env bash

# create pf dir
existingDirs=$(ls -d $HOME/.IntelliJIdea* $HOME/.intellij-idea* 2>/dev/null)
echo "Existing Intellij Idea directories:"
echo "$existingDirs"
echo -e -n "${CYAN}Enter path to intellij home directory${NC}: "
read intellijHomeDir
makeDir $intellijHomeDir

. intellij-idea/jdk-table.sh