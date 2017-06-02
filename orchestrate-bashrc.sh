#!/usr/bin/env bash
rc=~/.bashrc
var=~/.bash_variables

if [ ! -f $var ]; then
	echo -e "${CYAN}File $var does not exist${NC}"
fi

if grep -q "$var" "$rc"; then
	echo -e "${GREEN}$rc loads $var${NC}"
else
	echo -e "${CYAN}modifying $rc to load $var${NC}"
	echo "if [ -f $var ]; then" >> $rc
	echo "  . $var" >> $rc
	echo "fi" >> $rc
fi