#!/usr/bin/env bash

configurePasswordDefault="n"
echo -e -n "${CYAN}Configure passwords [y/n]${NC} ($configurePasswordDefault): "
read configurePassword
configurePassword=${configurePassword:-$configurePasswordDefaul}

if [ "$configurePassword" == "y" ]; then

	publicKey=~/.ssh/id_rsa.pub.pem
	prvKey=~/.ssh/id_rsa
	if [ ! -f $publicKey ]; then
		openssl rsa -in ~/.ssh/id_rsa -pubout > $publicKey
	fi

	account=memouser@ds036617.mlab.com
	echo -e -n "${CYAN} password for $account: ${NC}"
	read -s accountPassword
	echo "$accountPassword" | openssl rsautl -encrypt -pubin -inkey $publicKey > ~/.ssh/$account

fi

