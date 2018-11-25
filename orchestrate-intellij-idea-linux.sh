#!/usr/bin/env bash

if [[ "$system" == "linux" ]]; then

  untarFamily intellij-idea "" "sed 's/ideaIU-/intellij-idea-/g'"

  # remove previous desktop launchers
  sudo rm -rf /usr/share/applications/intellij*


  for spec in `ls -d $pfDir/intellij-idea/* 2>/dev/null`; do
    version=`echo $spec | awk -F- '{print $NF}'`
    configDir="$HOME/.IntelliJIdea$version/config"
    makeDir $configDir

    # add memory customization
    cat > $configDir/idea64.vmoptions << EOL
-Xms512m
-Xmx2048m
EOL

    # create desktop launchers
    desktop=`cat << EOL
[Desktop Entry]
Name=IntelliJ $version
Comment=Intellij $version
Exec=$spec/bin/idea.sh
Icon=$spec/bin/idea.png
Terminal=false
Type=Application
EOL`

    echo "$desktop" | sudo tee /usr/share/applications/intellij-$version.desktop >/dev/null

  done

fi
