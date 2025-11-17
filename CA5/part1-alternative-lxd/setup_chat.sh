#!/bin/bash

echo "======================================"
echo "   SETUP DO CONTAINER: chat-app"
echo "======================================"

echo "Criar diretório /root/repo dentro do chat-app..."
lxc exec chat-app -- mkdir -p /root/repo

echo "Copiar projeto para o container..."
lxc file push -r ../../.. chat-app/root/repo/

echo "Instalar OpenJDK 17 e Gradle..."
lxc exec chat-app -- apt update -y
lxc exec chat-app -- apt install -y openjdk-17-jdk git gradle

echo "Fazer build do chat (./gradlew installDist)..."
lxc exec chat-app -- bash -c "cd /root/repo/cogsi2526-1211551-1250559-1250497/CA5/part1/app && chmod +x gradlew && ./gradlew installDist"

echo "Setup concluído!"
echo
echo "Para arrancar o chat server:"
echo "lxc exec chat-app -- bash -c \"cd /root/repo/cogsi2526-1211551-1250559-1250497/CA5/part1/app/build/install/basic_demo/lib && java -cp '*' basic_demo.ChatServerApp 59001\""

