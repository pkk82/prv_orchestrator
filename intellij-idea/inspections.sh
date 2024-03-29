#!/usr/bin/env bash

inspectionsFile=$intellijInspectionDir/pkk82.xml

cat > $inspectionsFile << EOL
<profile version="1.0">
  <option name="myName" value="pkk82" />
  <inspection_tool class="BashSimpleVarUsage" enabled="true" level="INFORMATION" enabled_by_default="true" />
  <inspection_tool class="WeakerAccess" enabled="true" level="WEAK WARNING" enabled_by_default="true">
    <option name="SUGGEST_PACKAGE_LOCAL_FOR_MEMBERS" value="true" />
    <option name="SUGGEST_PACKAGE_LOCAL_FOR_TOP_CLASSES" value="true" />
    <option name="SUGGEST_PRIVATE_FOR_INNERS" value="false" />
  </inspection_tool>
</profile>
EOL
