#!/usr/bin/env bash

otherXmlFile=$intellijOptionsDir/other.xml

cat > $otherXmlFile << EOL
<application>
  <component name="NodeJsLocalInterpreters">
EOL

nodeDir=$pfDir/nodejs
for specNode in `ls -d $nodeDir/*`; do
  version=$(echo $specNode | awk -F- '{print $NF}')
  finalSpecNode=`driveNotationWhenWindows "$specNode"`

  cat >> $otherXmlFile << EOL
    <local-interpreter path="$specNode/bin/node">
      <version-cache version="$version" />
    </local-interpreter>
EOL


done

cat >> $otherXmlFile << EOL
  </component>
</application>
EOL
