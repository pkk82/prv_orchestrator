#!/usr/bin/env bash

file=$intellijOptionsDir/ui.lnf.xml

cat > $file << EOL
<application>
  <component name="UISettings">
    <option name="EDITOR_TAB_PLACEMENT" value="2" />
    <option name="HIDE_TOOL_STRIPES" value="false" />
    <option name="MARK_MODIFIED_TABS_WITH_ASTERISK" value="true" />
    <option name="SHOW_MAIN_TOOLBAR" value="true" />
  </component>
</application>
EOL
