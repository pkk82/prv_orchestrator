#!/usr/bin/env bash

mvnPrvRepoUsername="pkk82"

mvnPrvRepoId="nexus.prv"
mvnPrvRepoUrl_="https://pkk82.pl/nexus"
mvnPrvRepoUrl="$mvnPrvRepoUrl_/repository/maven-group"

mvnPrvRepoReleaseId="nexus.prv.release"
mvnPrvRepoReleaseUrl="$mvnPrvRepoUrl_/repository/maven-releases"

mvnPrvRepoSnapshotId="nexus.prv.snapshot"
mvnPrvRepoSnapshotUrl="$mvnPrvRepoUrl_/repository/maven-snapshots"

echo "export MVN_PRV_REPO_USERNAME=$mvnPrvRepoUsername" >> $varFile

echo "export MVN_PRV_REPO_ID=$mvnPrvRepoId" >> $varFile
echo "export MVN_PRV_REPO_URL=$mvnPrvRepoUrl" >> $varFile

echo "export MVN_PRV_REPO_RELEASE_ID=$mvnPrvRepoReleaseId" >> $varFile
echo "export MVN_PRV_REPO_RELEASE_URL=$mvnPrvRepoReleaseUrl" >> $varFile

echo "export MVN_PRV_REPO_SNAPSHOT_ID=$mvnPrvRepoSnapshotId" >> $varFile
echo "export MVN_PRV_REPO_SNAPSHOT_URL=$mvnPrvRepoSnapshotUrl" >> $varFile

if [[ `askYN "Configure maven settings" "n"` == "y" ]]; then

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
  encryptedMavenPassword=`$MVN_HOME/bin/mvn --encrypt-master-password $mavenMasterPassword`

  echo "" > $mvnSecuritySettings
  chmod 0600 $mvnSecuritySettings

  cat >> $mvnSecuritySettings << EOL
<settingsSecurity>
    <master>$encryptedMavenPassword</master>
</settingsSecurity>
EOL


  ossSonatypePassword=`askPassword "Public repo (pkk@oss.sonatype.org) password"`
  printf "\n"
  encryptedOssSonatypePassword=`$MVN_HOME/bin/mvn --encrypt-password $ossSonatypePassword`

  mvnPrvRepoPassword=`askPassword "Prv repo ($mvnPrvRepoUsername@$mvnPrvRepoUrl)"`
  printf "\n"
  mvnPrvRepoPasswordEncrypted=`$MVN_HOME/bin/mvn --encrypt-password $mvnPrvRepoPassword`

  dockerIoPassword=`askPassword "Docker (pkk82@docker.io) password"`
  printf "\n"
  encryptedDockerIoPassword=`$MVN_HOME/bin/mvn --encrypt-password $dockerIoPassword`

  gpgKeyPassphrase=`askPassword "Local gpg password"`
  printf "\n"
  encryptedGpgKeyPassphrase=`$MVN_HOME/bin/mvn --encrypt-password $gpgKeyPassphrase`

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
            <id>$mvnPrvRepoId</id>
            <username>$mvnPrvRepoUsername</username>
            <password>$mvnPrvRepoPasswordEncrypted</password>
        </server>
        <server>
            <id>$mvnPrvRepoReleaseUrl</id>
            <username>$mvnPrvRepoUsername</username>
            <password>$mvnPrvRepoPasswordEncrypted</password>
        </server>
        <server>
            <id>$mvnPrvRepoSnapshotId</id>
            <username>$mvnPrvRepoUsername</username>
            <password>$mvnPrvRepoPasswordEncrypted</password>
        </server>
        <server>
            <id>gpg</id>
            <passphrase>$encryptedGpgKeyPassphrase</passphrase>
        </server>
    </servers>
    <profiles>
        <profile>
            <id>repo.prv</id>
            <repositories>
                <repository>
                    <id>$mvnPrvRepoId</id>
                    <url>$mvnPrvRepoUrl</url>
                </repository>
            </repositories>
            <properties>
                <repo.id>$mvnPrvRepoId</repo.id>
                <repo.url>$mvnPrvRepoUrl_</repo.url>
                <repo.snapshot.id>$mvnPrvRepoSnapshotId</repo.snapshot.id>
                <repo.snapshot.url>$mvnPrvRepoSnapshotUrl</repo.snapshot.url>
                <repo.release.id>$mvnPrvRepoReleaseId</repo.release.id>
                <repo.release.url>$mvnPrvRepoReleaseUrl</repo.release.url>
            </properties>
            <activation>
                <activeByDefault>true</activeByDefault>
            </activation>
        </profile>
        <profile>
            <id>gpg</id>
            <properties>
                <gpg.passphraseServerId>gpg</gpg.passphraseServerId>
            </properties>
            <activation>
                <activeByDefault>true</activeByDefault>
            </activation>
        </profile>
    </profiles>
</settings>
EOL

fi
