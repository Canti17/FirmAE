#!/bin/bash
set -e
echo -e "\033[32m[*]\033[0m Waiting for DB to restart..."

# Start database
sudo service postgresql restart
sleep 3
