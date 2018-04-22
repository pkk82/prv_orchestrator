#!/usr/bin/env bash

configureIntellijDefault="n"
echo -e -n "${CYAN}Configure intellij idea settings [y/n]${NC} ($configureIntellijDefault): "
read configureIntellij
configureIntellij=${configureIntellij:-$configureIntellijDefault}

if [ "$configureIntellij" == "y" ]; then

	existingDirs=$(ls -d $HOME/.IntelliJIdea* $HOME/.intellij-idea* $HOME/Library/Preferences/IntelliJIdea* 2>/dev/null)
	echo "Existing Intellij Idea directories:"
	echo "$existingDirs"
	echo -e -n "${CYAN}Enter path to intellij home directory${NC}: "
	read intellijHomeDir
	makeDir $intellijHomeDir
	. intellij-idea/jdk-table.sh

fi;