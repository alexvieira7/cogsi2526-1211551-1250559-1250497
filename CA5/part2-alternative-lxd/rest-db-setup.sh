#!/bin/bash

# === SETUP DO CONTAINER rest-db ===

# Criar o container
lxc launch images:ubuntu/22.04 rest-db

# Instalar Java e ferramentas
lxc exec rest-db -- apt update
lxc exec rest-db -- apt install -y openjdk-17-jre wget

# Criar diretório do H2
lxc exec rest-db -- mkdir -p /opt/h2

# Fazer download do H2
lxc exec rest-db -- wget -O /opt/h2/h2.jar \
  https://repo1.maven.org/maven2/com/h2database/h2/2.2
