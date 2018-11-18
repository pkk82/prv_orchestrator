#!/usr/bin/env bash

jdkTableXmlFile=$intellijOptionsDir/jdk.table.xml

cat > $jdkTableXmlFile << EOL
<application>
  <component name="ProjectJdkTable">
EOL


for familyDir in `ls -d $pfDir/java*`; do

  vendor=`echo $familyDir | awk -F/ '{print $NF}' | awk -F- '{print $2}'`
  if [[ $vendor == "" ]]; then
    vendor="oracle"
  fi

  for specJava in `ls -d $familyDir/*`; do


    javaVersion=`echo $specJava | awk -F- '{print $(NF-1)}'`
    platform=`echo $specJava | awk -F- '{print $NF}'`
    finalSpecJava=`driveNotationWhenWindows "$specJava"`

    cat >> $jdkTableXmlFile << EOL
    <jdk version="2">
      <name value="$vendor-$javaVersion $platform" />
      <type value="JavaSDK" />
      <version value="java version &quot;$javaVersion&quot;" />
      <homePath value="$finalSpecJava" />
      <roots>
        <annotationsPath>
          <root type="composite">
            <root type="simple" url="jar://\$APPLICATION_HOME_DIR\$/lib/jdkAnnotations.jar!/" />
          </root>
        </annotationsPath>
        <classPath>
          <root type="composite">
EOL

    # before java 9
    for jarFile in `find $specJava/jre -name \*.jar 2>/dev/null`; do
      finalJarFile=`driveNotationWhenWindows "$jarFile"`
      cat >> $jdkTableXmlFile << EOL
            <root type="simple" url="jar://$finalJarFile!/" />
EOL
    done

  # after java 8
    for jmodFilePath in `find $specJava/jmods -name \*.jmod 2>/dev/null`; do
      jmodFile=`basename $jmodFilePath | sed 's/\.jmod//g'`
      cat >> $jdkTableXmlFile << EOL
          <root type="simple" url="jrt://$finalSpecJava!/$jmodFile" />
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

  # before java 9
    for zipFile in `ls -f $specJava/*.zip 2>/dev/null`; do
      finalZipFile=`driveNotationWhenWindows "$zipFile"`
      cat >> $jdkTableXmlFile << EOL
            <root type="simple" url="jar://$finalZipFile!/" />
EOL
    done

  # after java 8
    srcFile="$specJava/lib/src.zip"
    if [ -f "$srcFile" ]; then
      inZip=`zipinfo -1  "$srcFile" | awk -F/ '{print $1}' | uniq`
      finalSrcFile=`driveNotationWhenWindows "$srcFile"`
      for path in $inZip; do
        cat >> $jdkTableXmlFile << EOL
            <root type="simple" url="jar://$finalSrcFile!/$path" />
EOL
      done
    fi

    cat >> $jdkTableXmlFile << EOL
          </root>
        </sourcePath>
      </roots>
      <additional />
    </jdk>

EOL

  done

done

cat >> $jdkTableXmlFile << EOL
  </component>
</application>
EOL
