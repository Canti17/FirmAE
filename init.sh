#!/bin/bash
set -e

# Start database
sudo service postgresql restart
echo -e "\033[32m[*]\033[0m Waiting for DB to restart..."
sleep 3
