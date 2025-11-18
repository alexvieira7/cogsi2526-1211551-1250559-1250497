#!/bin/bash

# === SETUP DO CONTAINER rest-web ===

# Criar o container
lxc launch images:ubuntu/22.04 rest-web

# Instalar Java
lxc exec rest-web -- apt update
lxc exec rest-web -- apt install -y openjdk-17-jre

# Criar diretório para o JAR
lxc exec rest-web -- mkdir -p /root/app

# Enviar o JAR compilado do host para o container
lxc file push \
  ./CA2/CA2-part2/rest/build/libs/rest-0.0.1-SNAPSHOT.jar \
  rest-web/root/app/app.jar

# Obter IP da base de dados
DB_IP=$(lxc list rest-db -c 4 --format csv | awk '{print $1}')

echo "A usar DB IP: $DB_IP"

# Arrancar o Spring Boot com variáveis de ambiente
lxc exec rest-web -- bash -c "
  SPRING_DATASOURCE_URL='jdbc:h2:tcp://$DB_IP:9092/./payrolldb;DB_CLOSE_DELAY=-1;DB_CLOSE_ON_EXIT=FALSE' \
  SPRING_DATASOURCE_USERNAME='sa' \
  SPRING_DATASOURCE_PASSWORD='' \
  SPRING_JPA_HIBERNATE_DDL_AUTO='create' \
  nohup java -jar /root/app/app.jar > /root/spring.log 2>&1 &
"

echo "rest-web configurado e Spring Boot iniciado."
