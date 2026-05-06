#!/usr/bin/env bash
set -euo pipefail

# Instalação do OBS Studio + plugin obs-multi-rtmp no Ubuntu/Debian

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info()    { echo -e "${GREEN}[INFO]${NC} $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC} $*"; }
error()   { echo -e "${RED}[ERRO]${NC} $*"; exit 1; }

# --- Verificações iniciais ---

[[ "$(id -u)" -eq 0 ]] || error "Execute como root ou com sudo: sudo bash $0"

if ! command -v apt-get &>/dev/null; then
    error "Este script requer um sistema Ubuntu/Debian com apt-get."
fi

DISTRO=$(. /etc/os-release && echo "$ID")
CODENAME=$(. /etc/os-release && echo "$VERSION_CODENAME")
info "Distribuição detectada: $DISTRO $CODENAME"

# --- Dependências básicas ---

info "Instalando dependências..."
apt-get update -qq
apt-get install -y --no-install-recommends \
    wget curl ca-certificates \
    software-properties-common \
    gnupg lsb-release \
    jq

# --- OBS Studio ---

info "Adicionando PPA oficial do OBS Studio..."
add-apt-repository -y ppa:obsproject/obs-studio
apt-get update -qq

info "Instalando OBS Studio..."
apt-get install -y obs-studio

OBS_VERSION=$(obs-studio --version 2>/dev/null | grep -oP '\d+\.\d+\.\d+' | head -1 || dpkg -s obs-studio | grep Version | awk '{print $2}')
info "OBS Studio instalado: versão $OBS_VERSION"

# --- Plugin obs-multi-rtmp ---

info "Buscando versão mais recente do obs-multi-rtmp..."

GITHUB_API="https://api.github.com/repos/sorayuki/obs-multi-rtmp/releases/latest"
RELEASE_JSON=$(curl -fsSL "$GITHUB_API")
PLUGIN_VERSION=$(echo "$RELEASE_JSON" | jq -r '.tag_name')
info "Versão do plugin: $PLUGIN_VERSION"

# Procura asset Linux (prioriza pacote .deb, depois .tar.gz)
DEB_URL=$(echo "$RELEASE_JSON" | jq -r '.assets[] | select(.name | test("ubuntu|linux|deb"; "i")) | .browser_download_url' | head -1)
TAR_URL=$(echo "$RELEASE_JSON" | jq -r '.assets[] | select(.name | test("\\.tar\\.gz$|\\.tar\\.xz$"; "i")) | .browser_download_url' | head -1)

PLUGIN_DIR_SYSTEM="/usr/lib/x86_64-linux-gnu/obs-plugins"
PLUGIN_DATA_DIR="/usr/share/obs/obs-plugins/obs-multi-rtmp"
PLUGIN_DIR_USER="$HOME/.config/obs-studio/plugins/obs-multi-rtmp"

TMPDIR_PLUGIN=$(mktemp -d)
trap 'rm -rf "$TMPDIR_PLUGIN"' EXIT

if [[ -n "$DEB_URL" ]]; then
    info "Baixando pacote .deb: $DEB_URL"
    wget -q --show-progress -O "$TMPDIR_PLUGIN/obs-multi-rtmp.deb" "$DEB_URL"
    dpkg -i "$TMPDIR_PLUGIN/obs-multi-rtmp.deb" || apt-get install -fy
    info "Plugin instalado via .deb"

elif [[ -n "$TAR_URL" ]]; then
    info "Baixando arquivo: $TAR_URL"
    wget -q --show-progress -O "$TMPDIR_PLUGIN/obs-multi-rtmp.tar.gz" "$TAR_URL"
    tar -xf "$TMPDIR_PLUGIN/obs-multi-rtmp.tar.gz" -C "$TMPDIR_PLUGIN"

    # Instala .so no diretório de plugins do sistema
    mkdir -p "$PLUGIN_DIR_SYSTEM" "$PLUGIN_DATA_DIR"
    find "$TMPDIR_PLUGIN" -name "obs-multi-rtmp.so" -exec cp -v {} "$PLUGIN_DIR_SYSTEM/" \;
    find "$TMPDIR_PLUGIN" -name "locale" -type d -exec cp -rv {} "$PLUGIN_DATA_DIR/" \;
    info "Plugin instalado em $PLUGIN_DIR_SYSTEM"

else
    warn "Nenhum binário Linux encontrado nos releases. Tentando instalação manual no diretório do usuário..."

    # Fallback: instala via diretório do usuário
    mkdir -p "$PLUGIN_DIR_USER/bin/64bit" "$PLUGIN_DIR_USER/data/locale"

    FALLBACK_URL=$(echo "$RELEASE_JSON" | jq -r '.assets[0].browser_download_url // empty')
    if [[ -n "$FALLBACK_URL" ]]; then
        wget -q --show-progress -O "$TMPDIR_PLUGIN/plugin_file" "$FALLBACK_URL"
        warn "Arquivo baixado em $TMPDIR_PLUGIN/plugin_file — instale manualmente em $PLUGIN_DIR_USER/bin/64bit/"
    else
        warn "Nenhum asset disponível. Consulte: https://github.com/sorayuki/obs-multi-rtmp/releases"
    fi
fi

# --- Conclusão ---

echo ""
echo -e "${GREEN}=================================================${NC}"
echo -e "${GREEN}  OBS Studio + obs-multi-rtmp instalados!${NC}"
echo -e "${GREEN}=================================================${NC}"
echo ""
echo "  OBS Studio versão : $OBS_VERSION"
echo "  Plugin versão     : $PLUGIN_VERSION"
echo ""
echo "  Para usar o plugin:"
echo "    1. Abra o OBS Studio"
echo "    2. Vá em Ferramentas → Múltiplos destinos RTMP"
echo "    3. Adicione suas URLs de stream (YouTube, Twitch, etc.)"
echo ""
echo "  Documentação do plugin:"
echo "    https://github.com/sorayuki/obs-multi-rtmp"
echo ""
