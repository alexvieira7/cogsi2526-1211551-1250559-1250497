#!/bin/bash

GREEN_IP=192.168.56.11

echo "Checking health on GREEN VM..."

STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://$GREEN_IP:8080)

if [[ "$STATUS" == "200" || "$STATUS" == "404" ]]; then
  echo "[OK] Deployment is healthy. Status code: $STATUS"
  exit 0
else
  echo "[ERROR] Health check failed."
  echo "Status code: $STATUS"
  exit 1
fi
