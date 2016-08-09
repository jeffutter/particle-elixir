#!/usr/bin/env bash

## Setup hex user
mkdir -p ~/.hex  
echo '{username,<<"'${HEX_USERNAME}'">>}.' > ~/.hex/hex.config  
echo '{encrypted_key,<<"'${HEX_KEY}'">>}.' >> ~/.hex/hex.config

echo "Deploying"

mix hex.publish <<EOF
${HEX_PASSPHRASE}
y
EOF
