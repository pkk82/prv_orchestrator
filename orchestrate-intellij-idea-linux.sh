#!/usr/bin/env bash

if [[ "$system" == "linux" ]]; then

  untarFamily intellij-idea "" "sed 's/ideaIU-/intellij-idea-/g'"

  # add memory customization
  for spec in `ls -d $pfDir/intellij-idea/* 2>/dev/null`; do
    version=`echo $spec | awk -F- '{print $NF}'`
    configDir="$HOME/.IntelliJIdea$version/config"
    makeDir $configDir

    cat > $configDir/idea64.vmoptions << EOL
-Xms512m
-Xmx2048m
EOL
  done

fi
