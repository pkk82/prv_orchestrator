#!/usr/bin/env bash
# copy kafka to pf
kafkaDir=$pfDir/kafka
makeDir $kafkaDir
for kafkaTgz in `ls -d $cloudDir/kafka/*.tgz`; do
	tarDir=$(tar tzf $kafkaTgz | sed -e 's|/.*||' | uniq)
	tarDir=${tarDir%/}
	destFolder=$kafkaDir/$tarDir
	if [ -d "$destFolder" ]; then
		echo -e "${CYAN}Dir $destFolder exists - skipping${NC}"
	else
		tar -zxf $kafkaTgz -C $kafkaDir
		echo "$kafkaTgz extracted to $kafkaDir"
	fi
done


#add kafka variables
maxVersion=0
echo "# kafka" >> $varFile
for specKafka in `ls -d $kafkaDir/*`; do
	version=$(echo $specKafka | awk -F/ '{print $(NF)}' | sed 's/kafka_\(.*\)/\1/')
	kafkaMajorVersion=$(echo $version | cut -d- -f2 | cut -d. -f2)
	kafkaMinorVersion=$(echo $version | cut -d- -f2 | cut -d. -f3)
	scalaVersion=$(echo $version | cut -d- -f1 | cut -d. -f2)

	varName="KAFKA${kafkaMajorVersion}_${kafkaMinorVersion}_${scalaVersion}_HOME"
	echo "export $varName=$specKafka" | sed "s|$pfDir|\$PF_DIR|" >> $varFile
	currVersion=$((10000 * kafkaMajorVersion + 100 * $kafkaMinorVersion + $scalaVersion))
	if [[ $currVersion -gt  $maxVersion ]]; then
		maxVersion=$currVersion
		latestPath=$varName
	fi
done

echo "export KAFKA_HOME=\$$latestPath" >> $varFile




