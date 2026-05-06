FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=America/Sao_Paulo
ENV DISPLAY=:1
ENV RESOLUTION=1280x800x24

# Dependências base + OBS Studio
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget curl ca-certificates gnupg jq \
    software-properties-common \
    # Interface gráfica virtual
    xvfb x11vnc \
    # noVNC para acesso via browser
    novnc websockify \
    # Fonts e utilitários
    xfonts-base xfonts-75dpi xfonts-100dpi \
    dbus-x11 \
    # OBS PPA e instalação
    && add-apt-repository -y ppa:obsproject/obs-studio \
    && apt-get update \
    && apt-get install -y obs-studio \
    && rm -rf /var/lib/apt/lists/*

# Instala plugin obs-multi-rtmp
RUN set -e; \
    RELEASE_JSON=$(curl -fsSL https://api.github.com/repos/sorayuki/obs-multi-rtmp/releases/latest); \
    PLUGIN_VERSION=$(echo "$RELEASE_JSON" | jq -r '.tag_name'); \
    echo "Instalando obs-multi-rtmp $PLUGIN_VERSION"; \
    DEB_URL=$(echo "$RELEASE_JSON" | jq -r '.assets[] | select(.name | test("ubuntu|linux|deb"; "i")) | .browser_download_url' | head -1); \
    TAR_URL=$(echo "$RELEASE_JSON" | jq -r '.assets[] | select(.name | test("\\.tar\\.gz$|\\.tar\\.xz$"; "i")) | .browser_download_url' | head -1); \
    TMPDIR=$(mktemp -d); \
    if [ -n "$DEB_URL" ]; then \
        wget -q -O "$TMPDIR/plugin.deb" "$DEB_URL"; \
        dpkg -i "$TMPDIR/plugin.deb" || apt-get install -fy; \
    elif [ -n "$TAR_URL" ]; then \
        wget -q -O "$TMPDIR/plugin.tar.gz" "$TAR_URL"; \
        tar -xf "$TMPDIR/plugin.tar.gz" -C "$TMPDIR"; \
        mkdir -p /usr/lib/x86_64-linux-gnu/obs-plugins /usr/share/obs/obs-plugins/obs-multi-rtmp; \
        find "$TMPDIR" -name "obs-multi-rtmp.so" -exec cp {} /usr/lib/x86_64-linux-gnu/obs-plugins/ \; ; \
        find "$TMPDIR" -name "locale" -type d -exec cp -r {} /usr/share/obs/obs-plugins/obs-multi-rtmp/ \; ; \
    else \
        echo "AVISO: Nenhum binário Linux encontrado. Plugin será necessário instalar manualmente."; \
    fi; \
    rm -rf "$TMPDIR"

# Diretório de configuração do OBS
RUN mkdir -p /root/.config/obs-studio

# Copia script de entrypoint
COPY scripts/docker-entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# noVNC - expõe acesso web na porta 6080
# VNC direto na porta 5900
EXPOSE 6080 5900

VOLUME ["/root/.config/obs-studio"]

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
