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
   <template name="QM" value="&quot;\$SELECTION\$&quot;" shortcut="NONE" description="Surround with &quot;&quot;" toReformat="false" toShortenFQNames="true">
    <context>
      <option name="OTHER" value="true" />
    </context>
  </template>
  <template name="A" value="'\$SELECTION\$'" shortcut="NONE" description="Surround with ''" toReformat="false" toShortenFQNames="true">
    <context>
      <option name="OTHER" value="true" />
    </context>
  </template>
</templateSet>
EOL


ownXmlFile=$intellijTemplatesDir/own.xml
cat > $ownXmlFile << EOL
<templateSet group="own">
  <template name="slf4j" value="private final static org.slf4j.Logger LOG = org.slf4j.LoggerFactory.getLogger(\$PACKAGE\$.\$CLASS\$.class);\$END\$" description="static slf4j logger" toReformat="false" toShortenFQNames="true">
    <variable name="PACKAGE" expression="currentPackage()" defaultValue="" alwaysStopAt="true" />
    <variable name="CLASS" expression="className()" defaultValue="" alwaysStopAt="true" />
    <context>
      <option name="JAVA_DECLARATION" value="true" />
    </context>
  </template>
</templateSet>
EOL
