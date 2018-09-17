#!/usr/bin/env bash

configureIntellijDefault="n"
echo -e -n "${CYAN}Configure intellij idea settings [y/n]${NC} ($configureIntellijDefault): "
read configureIntellij
configureIntellij=${configureIntellij:-$configureIntellijDefault}

if [ "$configureIntellij" == "y" ]; then

	existingDirs=`ls -d $HOME/.IntelliJIdea* $HOME/.intellij-idea* $HOME/Library/Preferences/IntelliJIdea* 2>/dev/null`
	intellijHomeDirDefault=`ls -d $HOME/.IntelliJIdea* $HOME/.intellij-idea* $HOME/Library/Preferences/IntelliJIdea* 2>/dev/null | sort | tail -n 1`

	echo "Existing Intellij Idea directories:"
	echo "$existingDirs"
	if [ "$intellijHomeDirDefault" == "" ]; then
		echo -e -n "${CYAN}Enter path to intellij home directory${NC}: "
	else
		echo -e -n "${CYAN}Enter path to intellij home directory${NC} ($intellijHomeDirDefault): "
	fi

	read intellijHomeDir
	intellijHomeDir=${intellijHomeDir:-$intellijHomeDirDefault}
	makeDir $intellijHomeDir

	if [ "$system" = "mac" ]; then
	  intellijOptionsDir=$intellijHomeDir/options
	else
	  intellijOptionsDir=$intellijHomeDir/config/options

	  intellijInspectionDir=$intellijHomeDir/config/inspection
	  makeDir $intellijInspectionDir

		intellijKeymapsDir=$intellijHomeDir/config/keymaps
	  makeDir $intellijKeymapsDir

		intellijTemplatesDir=$intellijHomeDir/config/templates
		makeDir $intellijTemplatesDir
	fi
	makeDir $intellijOptionsDir

	for shFile in `ls ./intellij-idea/*.sh`; do
		. $shFile
	done

fi;
