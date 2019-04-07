#!/usr/bin/env bash

if [[ `askYN "Configure passwords" "n"` == "y" ]]; then

  publicKey=~/.ssh/id_rsa.pub.pem
  prvKey=~/.ssh/id_rsa
  if [[ ! -f "$publicKey" ]]; then
    openssl rsa -in ~/.ssh/id_rsa -pubout > "$publicKey"
  fi

  mavenPrvPassword=`askPassword "Enter prv maven password"`
  printf "\n"
  mavenPrvPasswordEnc=`echo "$mavenPrvPassword" | openssl rsautl -encrypt -pubin -inkey "$publicKey" | openssl enc -base64 | tr '\n' ' '`

  echo "MVN_PRV_REPO_PASSWORD_ENC=$mavenPrvPasswordEnc" > ~/.passwords

fi

