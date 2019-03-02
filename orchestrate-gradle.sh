#!/usr/bin/env bash

# copy gradle to pf
unzipFamily gradle

### verify gradle works with Java 8
currentJavaVersion=$JAVA_HOME
JAVA_HOME=$JAVA8_x64_HOME
verifyVersion gradle "bin/gradle --version | grep Gradle | awk '{print \$2}'"

gradleDir=$pfDir/gradle
## verify gradle with appropriate Java version
for specGradle in `ls -d $gradleDir/* 2>/dev/null`; do
  gradleVersion=$(echo $specGradle | awk -F/ '{print $(NF)}' | sed 's/gradle-\(.*\)/\1/')
  major=$(echo $gradleVersion | cut -d'.' -f1)

  if (( major <= 1 )) && [[ ! -z $JAVA5_x64_HOME ]]; then
    JAVA_HOME=$JAVA5_x64_HOME
  elif (( major <= 2 )) && [[ ! -z $JAVA6_x64_HOME ]]; then
    JAVA_HOME=$JAVA6_x64_HOME
  elif (( major <= 4 )) && [[ ! -z $JAVA7_x64_HOME ]]; then
    JAVA_HOME=$JAVA7_x64_HOME
  else
    JAVA_HOME=$JAVA8_x64_HOME
  fi

  # verify version with specific java version
  expectedGradleVersion=$(echo $specGradle | awk -F/ '{print $(NF)}' | sed 's/gradle-\(.*\)/\1/')
  actualGradleVersion=$($specGradle/bin/gradle --version | grep Gradle | awk '{print $2}')
  if [[ $actualGradleVersion == "$expectedGradleVersion" ]]; then
    echo -e "${GREEN}Gradle version $expectedGradleVersion is working with $JAVA_HOME${NC}"
  else
    echo -e "${RED}Gradle version $expectedGradleVersion is not working with $JAVA_HOME${NC}"
  fi
done
JAVA_HOME=$currentJavaVersion


createVariables gradle gradle "awk -F- '{print \$NF}' | cut -d. -f1"
