#!/usr/bin/env bash
set -euo pipefail

sudo apt-get update -y
sudo apt-get install -y git openjdk-17-jdk openjdk-17-jre maven curl unzip netcat-openbsd ca-certificates

sudo mkdir -p /project/h2db
sudo chmod 777 /project/h2db
