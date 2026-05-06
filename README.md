# Psiquiatria Prática App (protótipo)

Aplicativo front-end (HTML/CSS/JS) que reúne as principais funcionalidades observadas no site `psiquiatriapratica.com.br`:

- Landing page da mentoria com proposta, módulos e oferta.
- Dashboard de aluno com progresso por módulos.
- Gamificação com pontuação e badges.
- Fórum com criação de posts.
- Geração e verificação de certificado digital.

## Como executar

Como é um app estático, basta abrir `index.html` no navegador.

Opcional com servidor local:

```bash
python3 -m http.server 8000
```

Depois acesse <http://localhost:8000>.

---

## Streaming ao Vivo com OBS Studio + obs-multi-rtmp

O plugin [obs-multi-rtmp](https://github.com/sorayuki/obs-multi-rtmp) permite transmitir simultaneamente para múltiplos destinos RTMP (YouTube, Twitch, etc.).

### Opção 1 — Instalação direta no sistema (Ubuntu/Debian)

```bash
sudo bash scripts/install-obs-rtmp.sh
```

Após a instalação, abra o OBS Studio e acesse **Ferramentas → Múltiplos destinos RTMP**.

### Opção 2 — Via Docker (acesso pelo browser)

Requer Docker e Docker Compose instalados.

```bash
# Inicia o container OBS
sudo bash scripts/start-obs-docker.sh start

# Acesse o OBS pelo browser:
# http://localhost:6080/vnc.html

# Para parar
sudo bash scripts/start-obs-docker.sh stop
```

Outros comandos do helper:

| Comando | Descrição |
|---------|-----------|
| `start` | Builda e inicia o container |
| `stop` | Para o container |
| `restart` | Reinicia o container |
| `logs` | Exibe logs em tempo real |
| `build` | Reconstrói a imagem |

### Estrutura dos arquivos de streaming

```
scripts/
├── install-obs-rtmp.sh     # Instalação direta no Ubuntu/Debian
├── start-obs-docker.sh     # Helper para gerenciar o container Docker
└── docker-entrypoint.sh    # Entrypoint interno do container
Dockerfile                  # Container Ubuntu + OBS + noVNC
docker-compose.yml          # Configuração do serviço Docker
```
