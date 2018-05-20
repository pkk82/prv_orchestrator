#!/usr/bin/env bash

backupsScript=~/backups.sh
cat > $backupsScript << EOL
# mongo memo
backupDir=/tmp
MONGODB_HOST=ds036617.mlab.com
MONGODB_PORT=36617
MONGODB_DBNAME=memo
fileName=\$MONGODB_DBNAME-\$(date +"%Y%m%d-%H%M")
MONGODB_USERNAME=memouser
MONGODB_PASSWORD=\$(cat ~/.ssh/\${MONGODB_USERNAME}@\${MONGODB_HOST} | openssl rsautl -decrypt -inkey ~/.ssh/id_rsa)
docker run --rm -v \$backupDir:/backup -u \$(id -u):\$(id -g) mongo:3.4.7 \
bash -c "mongodump --out /backup -h \$MONGODB_HOST --port \$MONGODB_PORT -u \$MONGODB_USERNAME -p \$MONGODB_PASSWORD -d \$MONGODB_DBNAME"
tar -cvzf \$backupDir/\${fileName}.tar.gz -C \$backupDir \$MONGODB_DBNAME
mv \$backupDir/\${fileName}.tar.gz $cloudDir/../backups/\${fileName}.tar.gz
rm -rf \$backupDir/\$MONGODB_DBNAME
EOL
chmod u+x $backupsScript