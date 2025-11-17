#!/bin/bash

echo "======================================"
echo "   SETUP DO CONTAINER: rest-app"
echo "======================================"

echo "Criar diretório /root/repo dentro do rest-app..."
lxc exec rest-app -- mkdir -p /root/repo

echo "Copiar projeto para o container..."
lxc file push -r ../../.. rest-app/root/repo/

echo "Instalar OpenJDK 17 e Gradle..."
lxc exec rest-app -- apt update -y
lxc exec rest-app -- apt install -y openjdk-17-jdk git gradle

echo "Fazer build da API REST (./gradlew build)..."
lxc exec rest-app -- bash -c "cd /root/repo/cogsi2526-1211551-1250559-1250497/CA2/CA2-part2/rest && chmod +x gradlew && ./gradlew build"

echo "Setup concluído!"
echo
echo "Para arrancar a API REST:"
echo "lxc exec rest-app -- bash -c \"cd /root/repo/cogsi2526-1211551-1250559-1250497/CA2/CA2-part2/rest/build/libs && java -jar rest-0.0.1-SNAPSHOT.jar\""

