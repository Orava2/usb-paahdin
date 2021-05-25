#!/bin/bash

echo "Checking changes..."
git reset --hard
git pull
echo ""
bash allowExecution.sh

echo -e "\nPäivitykset tarkistettu. Lopeta painamalla ENTER-näppäintä."
read
