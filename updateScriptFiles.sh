#!/bin/bash
echo "Checking changes..."
git reset --hard
git pull
echo ""
bash allowExecution.sh
