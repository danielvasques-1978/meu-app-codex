#!/usr/bin/env bash
set -euo pipefail

DISPLAY_NUM=${DISPLAY_NUM:-1}
VNC_PORT=${VNC_PORT:-5900}
NOVNC_PORT=${NOVNC_PORT:-6080}
RESOLUTION=${RESOLUTION:-1280x800x24}

cleanup() {
    kill "$(jobs -p)" 2>/dev/null || true
}
trap cleanup EXIT

echo "[entrypoint] Iniciando Xvfb no display :${DISPLAY_NUM}..."
Xvfb ":${DISPLAY_NUM}" -screen 0 "${RESOLUTION}" -ac +extension GLX +render -noreset &
XVFB_PID=$!
sleep 2

export DISPLAY=":${DISPLAY_NUM}"

echo "[entrypoint] Iniciando x11vnc na porta ${VNC_PORT}..."
x11vnc -display ":${DISPLAY_NUM}" \
    -forever -shared \
    -rfbport "${VNC_PORT}" \
    -nopw -bg -quiet

echo "[entrypoint] Iniciando noVNC na porta ${NOVNC_PORT}..."
websockify --web /usr/share/novnc/ \
    "${NOVNC_PORT}" \
    "localhost:${VNC_PORT}" &

echo ""
echo "========================================================"
echo "  OBS Studio pronto!"
echo "  Acesse pelo browser: http://localhost:${NOVNC_PORT}/vnc.html"
echo "  VNC direto: localhost:${VNC_PORT}"
echo "========================================================"
echo ""

echo "[entrypoint] Iniciando OBS Studio..."
exec obs --minimize-to-tray "$@"
