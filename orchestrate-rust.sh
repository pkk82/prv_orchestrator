#!/usr/bin/env bash


if [[ "$system" != "win" ]] && [[ `askYN "Install rust" "n"` == "y" ]]; then

  case "$system" in
    "mac") triple="x86_64-apple-darwin" ;;
    "linux") triple="x86_64-unknown-linux-gnu" ;;
  esac
  curl https://sh.rustup.rs -sSf | bash -s -- --no-modify-path --default-host "$triple" -y --default-toolchain stable

fi

if [[ -d "$HOME/.cargo/bin" ]]; then
  echo "# rust" >> "$varFile"
  echo "export PATH=\$HOME/.cargo/bin:\$PATH" >> "$varFile"
fi
