#!/usr/bin/env bash

if [ ! -f $varFile ]; then
	echo -e "${CYAN}File $varFile does not exist${NC}"
fi

if grep -q "$varFile" "$rcFile"; then
	echo -e "${GREEN}$rcFile loads $varFile${NC}"
else
	echo -e "${CYAN}modifying $rcFile to load $varFile${NC}"
	echo "if [ -f $varFile ]; then" >> $rcFile
	echo "  . $varFile" >> $rcFile
	echo "fi" >> $rcFile
fi

if grep -q "$aliasesFile" "$rcFile"; then
	echo -e "${GREEN}$rcFile loads $aliasesFile${NC}"
else
	echo -e "${CYAN}modifying $rcFile to load $aliasesFile${NC}"
	echo "if [ -f $aliasesFile ]; then" >> $rcFile
	echo "  . $aliasesFile" >> $rcFile
	echo "fi" >> $rcFile
fi

if grep -q "$functionsFile" "$rcFile"; then
	echo -e "${GREEN}$rcFile loads $functionsFile${NC}"
else
	echo -e "${CYAN}modifying $rcFile to load $functionsFile${NC}"
	echo "if [ -f $functionsFile ]; then" >> $rcFile
	echo "  . $functionsFile" >> $rcFile
	echo "fi" >> $rcFile
fi
