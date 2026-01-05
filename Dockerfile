FROM n8nio/n8n:latest

USER root

# Instala ffmpeg e suas dependências
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ffmpeg \
    && rm -rf /var/lib/apt/lists/*

# Verifica se o ffmpeg está instalado e funcionando
RUN ffmpeg -version

USER node