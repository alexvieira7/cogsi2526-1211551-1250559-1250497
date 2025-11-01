#!/usr/bin/env bash
set -euo pipefail

# -------- Variáveis de ambiente esperadas --------
# REPO_SSH        (ex: git@github.com:alexvieira7/CA3.git  ou  https://github.com/alexvieira7/CA3.git)
# APP_SUBPATH     (ex: CA3/CA3-part2)
# DB_HOST         (IP da VM db)
# DB_PORT         (default 9092)
# DB_PATH         (ex: /project/h2db/ca3-db)
# AUTO_START      (true/false)

# -------- Defaults seguros --------
USER_HOME="/home/ubuntu"
REPO_DIR="${REPO_DIR:-$USER_HOME/repo}"
APP_SUBPATH="${APP_SUBPATH:-CA3/CA3-part2}"
DB_PORT="${DB_PORT:-9092}"
DB_PATH="${DB_PATH:-/project/h2db/ca3-db}"
LOG_DIR="/var/log/ca3"
APP_DIR="$REPO_DIR/$(basename "${REPO_SSH%.git}")/$APP_SUBPATH"

sudo mkdir -p "$REPO_DIR" "$LOG_DIR"
sudo chown -R ubuntu:ubuntu "$REPO_DIR" "$LOG_DIR"

# -------- SSH known_hosts (evita prompt) --------
mkdir -p "$USER_HOME/.ssh"
chmod 700 "$USER_HOME/.ssh"
if ! ssh-keygen -F github.com >/dev/null 2>&1; then
  ssh-keyscan github.com >> "$USER_HOME/.ssh/known_hosts"
  chmod 600 "$USER_HOME/.ssh/known_hosts"
fi

# -------- Clone com fallback (SSH -> HTTPS) --------
if [ ! -d "$REPO_DIR/.cloned" ]; then
  : "${REPO_SSH:?REPO_SSH não definido}"
  echo "[APP] A clonar $REPO_SSH -> $REPO_DIR"
  CLONED=0
  for K in "$USER_HOME/.ssh/id_ed25519" "$USER_HOME/.ssh/id_rsa"; do
    if [ -f "$K" ]; then
      echo "[APP] A usar chave: $K"
      if GIT_SSH_COMMAND="ssh -i $K -o StrictHostKeyChecking=accept-new" \
         git clone --depth=1 "$REPO_SSH" "$REPO_DIR/$(basename "${REPO_SSH%.git}")"; then
        CLONED=1; break
      fi
    fi
  done
  if [ "$CLONED" -eq 0 ]; then
    # HTTPS fallback
    if [[ "$REPO_SSH" =~ ^git@github.com: ]]; then
      REPO_HTTPS="https://github.com/${REPO_SSH#git@github.com:}"
    else
      REPO_HTTPS="$REPO_SSH"
    fi
    echo "[APP] Falhou via SSH. A tentar HTTPS: $REPO_HTTPS"
    git clone --depth=1 "$REPO_HTTPS" "$REPO_DIR/$(basename "${REPO_HTTPS%.git}")"
  fi
  touch "$REPO_DIR/.cloned"
fi

# -------- application.properties para H2 (TCP server) --------
APP_SRC="$APP_DIR/src/main/resources"
mkdir -p "$APP_SRC"
cat > "$APP_SRC/application.properties" <<EOF
spring.datasource.url=jdbc:h2:tcp://$DB_HOST:$DB_PORT/$DB_PATH;DB_CLOSE_ON_EXIT=FALSE
spring.datasource.username=sa
spring.datasource.password=
spring.h2.console.enabled=true
spring.jpa.hibernate.ddl-auto=update
server.port=8080
management.endpoints.web.exposure.include=health,info
EOF

# -------- Build --------
LOG_FILE="$LOG_DIR/spring.log"
: > "$LOG_FILE"
if [ -x "$APP_DIR/mvnw" ]; then
  (cd "$APP_DIR" && ./mvnw -DskipTests clean package)
elif command -v mvn >/dev/null 2>&1; then
  (cd "$APP_DIR" && mvn -DskipTests clean package)
elif [ -x "$APP_DIR/gradlew" ]; then
  (cd "$APP_DIR" && ./gradlew build -x test)
else
  echo "[APP][ERRO] Não encontrei Maven/Gradle"; exit 1
fi

# -------- Run --------
JAR="$(ls "$APP_DIR"/target/*.jar 2>/dev/null | head -n1 || true)"
if [ -z "$JAR" ]; then
  # Gradle?
  JAR="$(ls "$APP_DIR"/build/libs/*.jar 2>/dev/null | head -n1 || true)"
fi
[ -n "$JAR" ] || { echo "[APP][ERRO] JAR não encontrado."; exit 1; }

pkill -f "java .*$(basename "$JAR")" || true
echo "[APP] A arrancar: $JAR (log: $LOG_FILE)"
nohup java -jar "$JAR" >> "$LOG_FILE" 2>&1 &

# Health-check rápido
sleep 5
if ss -tulpn | grep -q ":8080"; then
  echo "[APP] Porta 8080 a escutar."
else
  echo "[APP][ALERTA] Nada na 8080. Ver log: $LOG_FILE"
fi
