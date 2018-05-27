#!/usr/bin/env bash

macrosFile=$intellijOptionsDir/macros.xml

cat > $macrosFile << EOF
<application>
  <component name="ActionMacroManager">
    <macro name="format-on-save">
      <action id="ReformatCode" />
      <action id="OptimizeImports" />
      <action id="SaveAll" />
    </macro>
  </component>
</application>
EOF
