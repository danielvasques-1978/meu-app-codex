#!/usr/bin/env bash
set -euo pipefail

COMPOSE_FILE="$(cd "$(dirname "$0")/.." && pwd)/docker-compose.yml"
NOVNC_URL="http://localhost:6080/vnc.html"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info() { echo -e "${GREEN}[INFO]${NC} $*"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }

usage() {
    cat <<EOF
Uso: $(basename "$0") [comando]

Comandos:
  start    Constrói (se necessário) e inicia o OBS em container
  stop     Para o container
  restart  Reinicia o container
  logs     Exibe logs do container
  status   Mostra status do container
  build    Reconstrói a imagem (após alterações no Dockerfile)

Exemplos:
  sudo $(basename "$0") start
  sudo $(basename "$0") stop
  sudo $(basename "$0") logs
EOF
    exit 0
}

check_docker() {
    if ! command -v docker &>/dev/null; then
        echo "Docker não encontrado. Instale em: https://docs.docker.com/engine/install/ubuntu/"
        exit 1
    fi
    if ! command -v docker compose &>/dev/null && ! command -v docker-compose &>/dev/null; then
        echo "Docker Compose não encontrado."
        exit 1
    fi
}

compose_cmd() {
    if command -v docker compose &>/dev/null; then
        docker compose -f "$COMPOSE_FILE" "$@"
    else
        docker-compose -f "$COMPOSE_FILE" "$@"
    fi
}

CMD="${1:-help}"

check_docker

case "$CMD" in
    start)
        info "Iniciando OBS Studio em container..."
        compose_cmd up -d --build
        sleep 3
        info "Container iniciado!"
        echo ""
        echo -e "  Acesse o OBS pelo browser: ${GREEN}${NOVNC_URL}${NC}"
        echo "  Para parar: sudo $0 stop"
        echo ""
        ;;
    stop)
        info "Parando container OBS..."
        compose_cmd down
        info "Container parado."
        ;;
    restart)
        info "Reiniciando container OBS..."
        compose_cmd restart
        info "Container reiniciado. Acesse: $NOVNC_URL"
        ;;
    logs)
        compose_cmd logs -f obs
        ;;
    status)
        compose_cmd ps obs
        ;;
    build)
        info "Reconstruindo imagem OBS..."
        compose_cmd build --no-cache obs
        info "Imagem reconstruída. Execute: sudo $0 start"
        ;;
    help|--help|-h)
        usage
        ;;
    *)
        warn "Comando desconhecido: $CMD"
        usage
        ;;
esac
