#!/usr/bin/env bash

intellijHomeDirs=`ls -d $HOME/.IntelliJIdea* $HOME/.intellij-idea* $HOME/Library/Preferences/IntelliJIdea* 2>/dev/null`

if [[ "$intellijHomeDirs" == "" ]]; then
  echo -e -n "${CYAN}Enter path to intellij home directory${NC}: "
  read newIntellijHomeDir
  makeDir $newIntellijHomeDir
  intellijHomeDirs=($newIntellijHomeDir)
fi

for intellijHomeDir in $intellijHomeDirs; do

  if [[ "$system" = "mac" ]]; then
    intellijWorkingDir=$intellijHomeDir
  else
    intellijWorkingDir=$intellijHomeDir/config
  fi

  intellijOptionsDir=$intellijWorkingDir/options
  makeDir $intellijOptionsDir

  intellijInspectionDir=$intellijWorkingDir/inspection
  makeDir $intellijInspectionDir

  intellijKeymapsDir=$intellijWorkingDir/keymaps
  makeDir $intellijKeymapsDir

  intellijTemplatesDir=$intellijWorkingDir/templates
  makeDir $intellijTemplatesDir

  for shFile in `ls ./intellij-idea/*.sh`; do
    . $shFile
  done

done
