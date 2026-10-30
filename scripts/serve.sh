#!/usr/bin/env bash
# 启动或复用书架 HTTP 服务（默认端口 8931）
# 用法: serve.sh [port]
set -u
PORT="${1:-8931}"
SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DIR="$SKILL_DIR/assets/bookshelf"

if [ ! -f "$DIR/index.html" ]; then
  echo "ERROR: bookshelf not found at $DIR" >&2
  exit 1
fi

if curl -sf -o /dev/null "http://127.0.0.1:${PORT}/index.html"; then
  echo "already-running"
else
  nohup python3 -m http.server "$PORT" --bind 0.0.0.0 --directory "$DIR" >/tmp/bookshelf_http.log 2>&1 &
  sleep 1
  if ! curl -sf -o /dev/null "http://127.0.0.1:${PORT}/index.html"; then
    echo "ERROR: failed to start server" >&2
    tail -5 /tmp/bookshelf_http.log >&2
    exit 1
  fi
  echo "started"
fi

LOCAL_IP="$(hostname -I 2>/dev/null | awk '{print $1}')"
echo "local:  http://127.0.0.1:${PORT}"
[ -n "$LOCAL_IP" ] && echo "lan:    http://${LOCAL_IP}:${PORT}"
