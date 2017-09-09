#!/usr/bin/env bash
configureMvnDefault="n"
echo -e -n "${CYAN}Configure maven settings [y/n]${NC} ($configureMvnDefault): "
read configureMvn
configureMvn=${configureMvn:-$configureMvnDefault}

if [ "$configureMvn" == "y" ]; then

	dotM2=$HOME/.m2
	mkdir -p $dotM2

	mvnSettings=$dotM2/settings.xml
	mvnSecuritySettings=$dotM2/settings-security.xml

	rm -rf $mvnSettings

	echo -e -n "${CYAN}Maven master password: ${NC}"
	read -s mavenMasterPassword

	mavenMasterPasswordLength=${#mavenMasterPassword}
	printf "\nEncrypting master password "
	printf '.%.0s' $(seq 1 $mavenMasterPasswordLength)
	printf "\n"
	encryptedMavenPassword=$($MVN_HOME/bin/mvn --encrypt-master-password $mavenMasterPassword)

	echo "" > $mvnSecuritySettings
	chmod 0600 $mvnSecuritySettings

cat >> $mvnSecuritySettings << EOL
<settingsSecurity>
	<master>$encryptedMavenPassword</master>
</settingsSecurity>
EOL

	echo -e -n "${CYAN}Nexus (pkk@oss.sonatype.org) password: ${NC}"
	read -s ossSonatypePassword
	encryptedOssSonatypePassword=$($MVN_HOME/bin/mvn --encrypt-password $ossSonatypePassword)

	echo -e -n "\n${CYAN}Artifactory (pkk82@artifactory-pkk82pl.rhcloud.com) password: ${NC}"
	read -s artifactoryPassword
	encryptedArtifactoryPassword=$($MVN_HOME/bin/mvn --encrypt-password $artifactoryPassword)

	echo -e -n "\n${CYAN}Artifactory (pkk82@artifactory-pkk82.rhcloud.com) password: ${NC}"
	read -s artifactoryOldPassword
	encryptedArtifactoryOldPassword=$($MVN_HOME/bin/mvn --encrypt-password $artifactoryOldPassword)

	echo -e -n "\n${CYAN}Artifactory (pkk82@alibaba.cloud) password: ${NC}"
	read -s artifactoryCloudPassword
	encryptedArtifactoryCloudPassword=$($MVN_HOME/bin/mvn --encrypt-password $artifactoryCloudPassword)


cat > $mvnSettings << EOL
<?xml version="1.0" encoding="UTF-8"?>
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"
		xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
		xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0 http://maven.apache.org/xsd/settings-1.0.0.xsd">
	<servers>
		<server>
			<id>oss.sonatype.org</id>
			<username>pkk</username>
			<password>$encryptedOssSonatypePassword</password>
		</server>
		<server>
			<id>artifactory-pkk82pl.rhcloud.com-release</id>
			<username>pkk82</username>
			<password>$encryptedArtifactoryPassword</password>
		</server>
		<server>
			<id>artifactory-pkk82pl.rhcloud.com-snapshot</id>
			<username>pkk82</username>
			<password>$encryptedArtifactoryPassword</password>
		</server>
		<server>
			<id>artifactory-pkk82.rhcloud.com-release</id>
			<username>pkk82</username>
			<password>$encryptedArtifactoryOldPassword</password>
		</server>
		<server>
			<id>artifactory-pkk82.rhcloud.com-snapshot</id>
			<username>pkk82</username>
			<password>$encryptedArtifactoryOldPassword</password>
		</server>
		<server>
			<id>pkk82-artifactory-alibaba-cloud-release</id>
			<username>pkk82</username>
			<password>$encryptedArtifactoryCloudPassword</password>
		</server>
		<server>
			<id>pkk82-artifactory-alibaba-cloud-snapshot</id>
			<username>pkk82</username>
			<password>$encryptedArtifactoryCloudPassword</password>
		</server>
	</servers>
	<profiles>
		<profile>
			<id>repo-artifactory-pkk82.rhcloud.com-release</id>
			<repositories>
				<repository>
					<id>artifactory-pkk82.rhcloud.com-release</id>
					<url>http://artifactory-pkk82.rhcloud.com/artifactory/libs-release-local</url>
				</repository>
			</repositories>
			<activation>
				<activeByDefault>true</activeByDefault>
			</activation>
		</profile>
		<profile>
			<id>repo-pkk82-artifactory-alibaba-cloud-release</id>
			<repositories>
				<repository>
					<id>pkk82-artifactory-alibaba-cloud-release</id>
					<url>https://47.91.91.114:8444/artifactory/pkk82-mvn-repo-release</url>
				</repository>
			</repositories>
			<activation>
				<activeByDefault>true</activeByDefault>
			</activation>
		</profile>
	</profiles>
</settings>
EOL

fi