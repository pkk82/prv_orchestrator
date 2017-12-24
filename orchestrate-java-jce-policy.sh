#!/usr/bin/env bash
# copy policy to java
javaDir=$pfDir/java
securityPath="jre/lib/security"
for jceZip in `ls -d $cloudDir/java/jce-policy/*.zip`; do
	javaVersionFromPolicy=$(echo $jceZip | awk -F/ '{print $(NF)}' | sed 's/jce_policy-\(.*\).zip/\1/');
	for specJava in `ls -d $javaDir/jdk-*`; do
		javaVersion=$(echo $specJava | awk -F/ '{print $(NF)}' | awk -F- '{print $(NF-1)}' | cut -d'.' -f2)
		if [[ "$javaVersion" == "$javaVersionFromPolicy" ]]; then
			dstDir=${specJava}/${securityPath}
			exportPolicy=$dstDir/US_export_policy.jar
			exportPolicyBak=${exportPolicy}.bak
			if [[ -f $exportPolicyBak ]]; then
				echo -e "${CYAN}File $exportPolicyBak exists - skipping${NC}"
			elif [[ -f $exportPolicy ]]; then
				mv $exportPolicy $exportPolicyBak
			fi
			localPolicy=$dstDir/local_policy.jar
			localPolicyBak=${localPolicy}.bak
			if [[ -f $localPolicyBak ]]; then
				echo -e "${CYAN}File $localPolicyBak exists - skipping${NC}"
			elif [[ -f $localPolicy ]]; then
				mv $localPolicy $localPolicyBak
			fi
			unzip -o -j $jceZip **/*.jar -d $dstDir
		fi
	done
done



