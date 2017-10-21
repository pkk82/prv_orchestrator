#!/usr/bin/env bash
rc=~/.bashrc
aliases=~/.bash_aliases

cat > $aliases << EOL
alias dsa="docker stop \$(docker ps -q)"
alias dra="docker rm \$(docker ps -a -q)"
alias dria="docker rmi \$(docker images -q)"
alias dris="docker rmi \$(docker images | grep 'SNAPSHOT' | awk '{print \$3}')"
EOL
. $rc