#!/bin/bash
set -euo pipefail

REPO_SSH="${REPO_SSH:-}"
REPO_DIR="${REPO_DIR:-/home/vagrant/repo}"
REPO_NAME="$(basename -s .git "$REPO_SSH")"
TARGET="$REPO_DIR/$REPO_NAME"
AUTO_START="${AUTO_START:-true}"

mkdir -p "$REPO_DIR"
# evitar prompt de host key
mkdir -p /home/vagrant/.ssh
touch /home/vagrant/.ssh/known_hosts
ssh-keyscan -H github.com >> /home/vagrant/.ssh/known_hosts


if [ -z "$REPO_SSH" ]; then
  echo "REPO_SSH não definido. Sair."
  exit 1
fi

if [ -d "$TARGET/.git" ]; then
  echo "Repositório já existe: $TARGET"
  git -C "$TARGET" pull --rebase || true
else
  echo "A clonar $REPO_SSH para $TARGET ..."
  git clone "$REPO_SSH" "$TARGET"
fi

# tornar scripts executáveis se existirem
chmod +x "$TARGET/run_chat"    2>/dev/null || true
chmod +x "$TARGET/run_spring"  2>/dev/null || true

if [ "$AUTO_START" = "true" ]; then
  # Arranca apps em background se os scripts existirem
  [ -x "$TARGET/run_chat"   ] && ( "$TARGET/run_chat"   >/tmp/run_chat.log   2>&1 & )
  [ -x "$TARGET/run_spring" ] && ( "$TARGET/run_spring" >/tmp/run_spring.log 2>&1 & )
  echo "Aplicações (se existirem) arrancadas. Logs: /tmp/run_*.log"
fi

echo "Boot script concluído."
