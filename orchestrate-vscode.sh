#!/usr/bin/env bash

if [ "$system" == "linux" ]; then

dir=$HOME/.config/Code/User
file=$dir/settings.json

mkdir -p $dir
cat > $file << EOL
{
  "workbench.colorTheme": "Default Light+",
  "editor.renderWhitespace": "boundary"
}
EOL

fi;