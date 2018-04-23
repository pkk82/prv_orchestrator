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

  echo -e -n "\n${CYAN}Nexus (pkk82@nexus.pkk82.pl) password: ${NC}"
  read -s nexusCloudPassword
  encryptedNexusCloudPassword=$($MVN_HOME/bin/mvn --encrypt-password $nexusCloudPassword)

  echo -e -n "\n${CYAN}Docker (pkk82@docker.io) password: ${NC}"
  read -s dockerIoPassword
  encryptedDockerIoPassword=$($MVN_HOME/bin/mvn --encrypt-password $dockerIoPassword)

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
            <id>docker.io</id>
            <username>pkk82</username>
            <password>$encryptedDockerIoPassword</password>
        </server>
        <server>
            <id>pkk82-nexus</id>
            <username>pkk82</username>
            <password>$encryptedNexusCloudPassword</password>
        </server>
        <server>
            <id>pkk82-nexus-snapshots</id>
            <username>pkk82</username>
            <password>$encryptedNexusCloudPassword</password>
        </server>
        <server>
            <id>pkk82-nexus-releases</id>
            <username>pkk82</username>
            <password>$encryptedNexusCloudPassword</password>
        </server>
    </servers>
    <profiles>
        <profile>
            <id>repo-pkk82-nexus</id>
            <repositories>
                <repository>
                    <id>pkk82-nexus</id>
                    <url>https://pkk82.pl/nexus/repository/maven-group</url>
                </repository>
            </repositories>
            <properties>
                <repo.snapshot.id>pkk82-nexus-snapshots</repo.snapshot.id>
                <repo.snapshot.url>https://pkk82.pl/nexus/repository/maven-snapshots</repo.snapshot.url>
                repo.release.id>pkk82-nexus-releases</repo.release.id>
                <repo.release.url>https://pkk82.pl/nexus/repository/maven-releases</repo.release.url>
            </properties>
            <activation>
                <activeByDefault>true</activeByDefault>
            </activation>
        </profile>
    </profiles>
</settings>
EOL

fi
