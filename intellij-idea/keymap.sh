#!/usr/bin/env bash

keymapFile=$intellijOptionsDir/keymap.xml

if [ "$system" = "linux" ]; then
  name="keymap-gnome"
fi

cat > $keymapFile << EOL
<application>
  <component name="KeymapManager">
    <active_keymap name="$name" />
  </component>
</application>
EOL

cat > $intellijKeymapsDir/keymap-gnome.xml << EOL
<keymap version="1" name="keymap-gnome" parent="Default for GNOME">
  <action id="ImportModule">
    <keyboard-shortcut first-keystroke="shift ctrl alt o" />
  </action>
</keymap>
EOL
