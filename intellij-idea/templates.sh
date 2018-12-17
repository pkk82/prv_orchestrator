#!/usr/bin/env bash

javaScriptXmlFile=$intellijTemplatesDir/JavaScript.xml

cat > $javaScriptXmlFile << EOL
<templateSet group="JavaScript">
  <template name="iife" value="(function () {&#10;    'use strict';&#10;    $END$&#10;}());" description="Inserts immediately-invoked function expression" toReformat="true" toShortenFQNames="true">
    <context>
      <option name="JS_STATEMENT" value="true" />
    </context>
  </template>
</templateSet>
EOL

surroundXmlFile=$intellijTemplatesDir/surround.xml

cat > $surroundXmlFile << EOL
<templateSet group="surround">
  <template name="PL" value="System.out.println(\$SELECTION\$)" description="Surround with println" toReformat="false" toShortenFQNames="true">
    <context>
      <option name="JAVA_STATEMENT" value="true" />
    </context>
  </template>
</templateSet>
EOL
