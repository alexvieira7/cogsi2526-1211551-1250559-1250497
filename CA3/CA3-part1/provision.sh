#!/bin/bash
set -e
export DEBIAN_FRONTEND=noninteractive

sudo apt-get update -y
sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y
sudo apt-get install -y git maven gradle openjdk-17-jdk openjdk-17-jre \
                        curl unzip netcat ufw

# pasta para dados persistentes do H2 via pasta sincronizada
sudo mkdir -p /project/h2db
sudo chmod 777 /project/h2db
