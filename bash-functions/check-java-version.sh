#!/usr/bin/env bash
function check-java-version {
  for jarFile in `ls -f ./*.jar 2>/dev/null`; do
    className=`jar tf $jarFile | grep .class | grep -v "[$]" | head -n 1 | sed s/.class//g`
    version=`javap -verbose -classpath $jarFile $className | grep 'major version:' | awk '{print $(NF)}'`
    case $version in
      52) javaVersion="8"
        ;;
      51) javaVersion="7"
        ;;
      50) javaVersion="6"
        ;;
      49) javaVersion="5"
        ;;
      48) javaVersion="1.4"
        ;;
      47) javaVersion="1.3"
        ;;
      46) javaVersion="1.2"
        ;;
      45) javaVersion="1.0 or 1.1"
        ;;
      *) javaVersion="unknown"
        ;;
    esac
    echo "$jarFile - java version: $javaVersion"
  done
}
