#!/bin/bash
echo "Checking changes..."
git reset --hard
git pull
echo ""
bash allowExecution.sh

echo -e "\nP�ivitykset tarkistettu. Lopeta painamalla ENTER-n�pp�int�."
read
