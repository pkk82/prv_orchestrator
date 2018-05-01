#!/usr/bin/env bash

ideGeneralFile=$intellijOptionsDir/ide.general.xml

cat > $ideGeneralFile << EOL
<application>
  <component name="GeneralSettings">
    <option name="confirmExit" value="false" />
    <option name="reopenLastProject" value="false" />
    <option name="showTipsOnStartup" value="false" />
  </component>
</application>
EOL
