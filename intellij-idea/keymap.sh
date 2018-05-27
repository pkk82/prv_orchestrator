#!/usr/bin/env bash

keymapFile=$intellijOptionsDir/keymap.xml

gnomeName="keymap-gnome"
macName="keymap-mac"

if [ "$system" == "linux" ]; then
  name=$gnomeName
elif [ "$system" == "mac"  ]; then
  name=$macName
fi

cat > $keymapFile << EOL
<application>
  <component name="KeymapManager">
    <active_keymap name="$name" />
  </component>
</application>
EOL

cat > $intellijKeymapsDir/keymap-gnome.xml << EOL
<keymap version="1" name="$gnomeName" parent="Default for GNOME">
  <action id="CloseAllEditors">
    <keyboard-shortcut first-keystroke="shift ctrl alt 4" />
  </action>
  <action id="ImportModule">
    <keyboard-shortcut first-keystroke="shift ctrl alt o" />
  </action>
  <action id="Macro.format-on-save">
   <keyboard-shortcut first-keystroke="ctrl alt s" />
  </action>
  <action id="Maven.ReimportProject">
   <keyboard-shortcut first-keystroke="shift ctrl alt r" />
  </action>
  <action id="ShowProjectStructureSettings">
    <keyboard-shortcut first-keystroke="ctrl semicolon" />
  </action>
  <action id="ShowSettings">
    <keyboard-shortcut first-keystroke="ctrl comma" />
  </action>
  <action id="Back">
    <keyboard-shortcut first-keystroke="ctrl alt left" />
  </action>
  <action id="Forward">
    <keyboard-shortcut first-keystroke="ctrl alt right" />
  </action>
</keymap>
EOL


cat > $intellijKeymapsDir/keymap-mac.xml << EOL
<keymap version="1" name="$macName" parent="Mac OS X 10.5+">
  <action id="CloseAllEditors">
    <keyboard-shortcut first-keystroke="shift ctrl meta 4" />
  </action>
  <action id="ImportModule">
    <keyboard-shortcut first-keystroke="shift ctrl meta o" />
  </action>
  <action id="Macro.format-on-save">
   <keyboard-shortcut first-keystroke="ctrl meta s" />
  </action>
  <action id="Maven.ReimportProject">
    <keyboard-shortcut first-keystroke="shift ctrl meta r" />
  </action>
  <action id="Back">
    <keyboard-shortcut first-keystroke="ctrl meta left" />
  </action>
  <action id="Forward">
    <keyboard-shortcut first-keystroke="ctrl meta right" />
  </action>
</keymap>
EOL
