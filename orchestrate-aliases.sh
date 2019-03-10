#!/usr/bin/env bash
aliases=~/.bash_aliases

if [[ "$system" == "mac" ]]; then
  cclip="alias cclip='pbcopy'"
else
  cclip="alias cclip='xclip -selection clipboard'"
fi

cat > $aliases << EOL
alias dsa='docker ps -q | xargs docker stop'
alias dra='docker ps -a -q | xargs docker rm'
alias dria='docker images -q | xargs docker rmi -f'
alias dris='docker images | grep SNAPSHOT | awk '\''{print \$3}'\'' | xargs docker rmi -f'
alias use-maven-wrapper='mvn -U -N io.takari:maven:wrapper'
alias ssh-nexus='ssh pkk82.pl -p 57185'
alias gpom='git push origin master'
alias vssh='vagrant ssh'
alias vdf='vagrant destroy -f'
alias vu='vagrant up'
$cclip
EOL
