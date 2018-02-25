#!/usr/bin/env bash

version=9.6.7
pgFolder="$pfDir/postgres"
destFolder="$pgFolder/postgres-$version"
if [ "$system" == "linux" ]; then
    if [ -d "$destFolder" ]; then
        echo -e "${CYAN}Dir $destFolder exists - skipping${NC}"
    else
        makeDir $pgFolder
        curl -s "https://get.enterprisedb.com/postgresql/postgresql-${version}-1-linux-x64-binaries.tar.gz" | tar xfz - --transform "s/pgsql/postgres-$version/" -C "$pgFolder"
    fi

    echo "# postgres" >> $varFile
    echo "export PG_HOME=$destFolder" | sed "s|$pfDir|\$PF_DIR|" >> $varFile
    echo "export PATH=\$PG_HOME/bin:\$PATH" >> $varFile
    . $varFile
fi

