#!/bin/bash

GREEN_IP=192.168.56.20

echo "Checking health on GREEN VM..."

STATUS=$(curl -s http://$GREEN_IP:8080/actuator/health)

if [[ $STATUS == *"UP"* ]]; then
  echo "[OK] Deployment is healthy."
  exit 0
else
  echo "[ERROR] Health check failed."
  echo "Response: $STATUS"
  exit 1
fi
