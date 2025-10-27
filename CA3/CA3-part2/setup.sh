#!/bin/bash
set -euo pipefail

# ====== VARS de ambiente vindas do Vagrantfile ======
REPO_SSH="${REPO_SSH:-}"
REPO_DIR="${REPO_DIR:-/home/vagrant/repo}"
AUTO_START="${AUTO_START:-true}"

# força o alvo para CA3/CA3-part2
APP_SUBPATH="${APP_SUBPATH:-CA3/CA3-part2}"

# ligação ao H2 (VM db)
DB_HOST="${DB_HOST:-192.168.56.10}"
DB_PORT="${DB_PORT:-9092}"
DB_PATH="${DB_PATH:-/project/h2db/ca3-db}"

if [ -z "$REPO_SSH" ]; then
  echo "[APP] REPO_SSH não definido"; exit 1
fi

# ====== Git clone/pull ======
mkdir -p "$REPO_DIR" /home/vagrant/.ssh
touch /home/vagrant/.ssh/known_hosts
ssh-keyscan -H github.com >> /home/vagrant/.ssh/known_hosts 2>/dev/null || true

REPO_NAME="$(basename -s .git "$REPO_SSH")"
TARGET="$REPO_DIR/$REPO_NAME"

if [ -d "$TARGET/.git" ]; then
  echo "[APP] Repo existe: $TARGET -> git pull --rebase"
  git -C "$TARGET" pull --rebase || true
else
  echo "[APP] A clonar $REPO_SSH -> $TARGET"
  git clone "$REPO_SSH" "$TARGET"
fi

PRJ_DIR="$TARGET/$APP_SUBPATH"
echo "[APP] Projeto alvo: $PRJ_DIR"
if [ ! -d "$PRJ_DIR" ]; then
  echo "[APP] ERRO: pasta não existe no repo: $PRJ_DIR"
  exit 0
fi

# ====== Build system detection (sem auto-criar nada!) ======
USE_MAVEN="no"; USE_GRADLE="no"
[ -f "$PRJ_DIR/pom.xml" ] && USE_MAVEN="yes"
{ [ -f "$PRJ_DIR/build.gradle" ] || [ -f "$PRJ_DIR/build.gradle.kts" ]; } && USE_GRADLE="yes"

if [ "$USE_MAVEN" = "no" ] && [ "$USE_GRADLE" = "no" ]; then
  echo "[APP] Não encontrei pom.xml/build.gradle em $PRJ_DIR."
  echo "[APP] Nada foi criado. Garante que o projeto 'employees' da CA3-part2 está aí."
  exit 0
fi

# ====== application.properties ======
mkdir -p "$PRJ_DIR/src/main/resources"
cat > "$PRJ_DIR/src/main/resources/application.properties" <<EOF
spring.datasource.url=jdbc:h2:tcp://$DB_HOST:$DB_PORT//$DB_PATH
spring.datasource.username=sa
spring.datasource.password=
spring.h2.console.enabled=true
spring.jpa.hibernate.ddl-auto=update
server.port=8080
management.endpoints.web.exposure.include=health,info
EOF
echo "[APP] application.properties escrito em $PRJ_DIR/src/main/resources/"

# ====== arranque controlado ======
if [ "$AUTO_START" = "true" ]; then
  echo "[APP] a fechar arranques antigos (se houver)…"
  pkill -f 'org.springframework.boot' || true
  pkill -f 'spring-boot:run' || true
  pkill -f 'GradleWrapperMain' || true
  sleep 1

  if [ "$USE_MAVEN" = "yes" ]; then
    echo "[APP] a arrancar via Maven…"
    ( cd "$PRJ_DIR" && mvn -DskipTests spring-boot:run >/tmp/run_spring.log 2>&1 & )
  else
    echo "[APP] a arrancar via Gradle…"
    ( cd "$PRJ_DIR" && ./gradlew bootRun >/tmp/run_spring.log 2>&1 & ) || true
  fi
  echo "[APP] Logs: /tmp/run_spring.log"
fi

echo "[APP] setup concluído."
