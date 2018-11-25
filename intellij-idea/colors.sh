#!/usr/bin/env bash

file=$intellijOptionsDir/colors.scheme.xml

cat > $file << EOL
<application>
  <component name="EditorColorsManagerImpl">
    <global_color_scheme name="_@user_Darcula" />
  </component>
</application>
EOL

