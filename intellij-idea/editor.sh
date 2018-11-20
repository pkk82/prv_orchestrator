#!/usr/bin/env bash

editorFile=$intellijOptionsDir/editor.xml

cat > $editorFile << EOL
<application>
  <component name="DefaultFont">
    <option name="FONT_SIZE" value="16" />
  </component>
  <component name="EditorSettings">
    <option name="IS_WHITESPACES_SHOWN" value="true" />
  </component>
</application>
EOL

editorFile=$intellijOptionsDir/editor.codeinsight.xml

cat > $editorFile << EOL
<application>
  <component name="DaemonCodeAnalyzerSettings" profile="pkk82">
    <option name="SHOW_METHOD_SEPARATORS" value="true" />
  </component>
</application>
EOL
