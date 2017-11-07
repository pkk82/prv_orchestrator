#!/usr/bin/env bash

jdkTableXmlFile=$intellijHomeDir/config/options/jdk.table.xml

cat > $jdkTableXmlFile << EOL
<application>
  <component name="ProjectJdkTable">
EOL

javaDir=$pfDir/java
for specJava in `ls -d $javaDir/*`; do
	fullJavaVersion=$(echo $specJava | awk -F- '{print $(NF-1)}' | tr 'u' '_')
	javaVersion=$(echo $specJava | awk -F- '{print $(NF-1)}' | cut -d'.' -f2)
	platform=$(echo $specJava | awk -F- '{print $NF}')
cat >> $jdkTableXmlFile << EOL

    <jdk version="2">
      <name value="1.$javaVersion $platform" />
      <type value="JavaSDK" />
      <version value="java version &quot;$fullJavaVersion&quot;" />
      <homePath value="$specJava" />
      <roots>
        <annotationsPath>
          <root type="composite">
            <root type="simple" url="jar://\$APPLICATION_HOME_DIR\$/lib/jdkAnnotations.jar!/" />
          </root>
        </annotationsPath>
        <classPath>
          <root type="composite">
EOL

	for jarFile in `find $specJava/jre -name \*.jar`; do
cat >> $jdkTableXmlFile << EOL
            <root type="simple" url="jar://$jarFile!/" />
EOL
	done

cat >> $jdkTableXmlFile << EOL
          </root>
        </classPath>
        <javadocPath>
          <root type="composite" />
        </javadocPath>
        <sourcePath>
          <root type="composite">
EOL

	for zipFile in `ls -f $specJava/*.zip`; do
cat >> $jdkTableXmlFile << EOL
            <root type="simple" url="jar://$zipFile!/" />
EOL
	done

cat >> $jdkTableXmlFile << EOL
          </root>
        </sourcePath>
      </roots>
      <additional />
    </jdk>

EOL

done


cat >> $jdkTableXmlFile << EOL
  </component>
</application>
EOL
