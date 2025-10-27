#!/bin/bash
set -e
export DEBIAN_FRONTEND=noninteractive

apt-get update -y
DEBIAN_FRONTEND=noninteractive apt-get upgrade -y

# comuns
apt-get install -y git maven openjdk-17-jdk openjdk-17-jre \
                   curl unzip netcat ufw

# pasta partilhada para dados H2 (acessível ao host)
mkdir -p /project/h2db
chmod 777 /project/h2db
