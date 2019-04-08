#!/usr/bin/env bash

file=$intellijOptionsDir/laf.xml

cat > $file << EOL
<application>
  <component name="LafManager">
    <laf class-name="com.intellij.ide.ui.laf.darcula.DarculaLaf" />
  </component>
</application>
EOL
