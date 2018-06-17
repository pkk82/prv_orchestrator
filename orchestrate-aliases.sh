#!/usr/bin/env bash
aliases=~/.bash_aliases

cat > $aliases << EOL
alias dsa='docker ps -q | xargs docker stop'
alias dra='docker ps -a -q | xargs docker rm'
alias dria='docker images -q | xargs docker rmi -f'
alias dris='docker images | grep SNAPSHOT | awk '\''{print \$3}'\'' | xargs docker rmi -f'
alias cclip='xclip -selection clipboard'
alias use-maven-wrapper='mvn -N io.takari:maven:wrapper'
alias ssh-nexus='ssh pkk82.pl -p 57185'
EOL
