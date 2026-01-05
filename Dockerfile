  FROM n8nio/n8n:latest
  
  USER root
  
# Detecta qual gerenciador de pacotes está disponível e instala ffmpeg
RUN if command -v apk > /dev/null; then \
        apk add --no-cache ffmpeg; \
    elif command -v apt-get > /dev/null; then \
        apt-get update && \
        apt-get install -y --no-install-recommends ffmpeg && \
        rm -rf /var/lib/apt/lists/*; \
    elif command -v yum > /dev/null; then \
        yum install -y ffmpeg && \
        yum clean all; \
    else \
        echo "Gerenciador de pacotes não encontrado. Baixando binário estático..."; \
        if command -v wget > /dev/null; then \
            DOWNLOAD_CMD="wget -q"; \
        elif command -v curl > /dev/null; then \
            DOWNLOAD_CMD="curl -sL"; \
        else \
            echo "ERRO: wget ou curl não encontrado"; \
            exit 1; \
        fi; \
        ARCH=$(uname -m); \
        if [ "$ARCH" = "x86_64" ]; then \
            ARCH="amd64"; \
        fi; \
        $DOWNLOAD_CMD https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-amd64-static.tar.xz -O /tmp/ffmpeg.tar.xz && \
        tar xf /tmp/ffmpeg.tar.xz -C /tmp && \
        cp /tmp/ffmpeg-*-static/ffmpeg /usr/local/bin/ && \
        cp /tmp/ffmpeg-*-static/ffprobe /usr/local/bin/ && \
        chmod +x /usr/local/bin/ffmpeg /usr/local/bin/ffprobe && \
        rm -rf /tmp/ffmpeg-* /tmp/ffmpeg.tar.xz; \
    fi

# Verifica se o ffmpeg está instalado (não falha o build se houver problema)
RUN ffmpeg -version || echo "AVISO: Verifique se ffmpeg foi instalado corretamente"

# Cria o diretório /data e garante permissões corretas para o usuário node
RUN mkdir -p /data && \
    chown -R node:node /data && \
    chmod -R 755 /data

# Garante que o diretório home do node também tenha permissões corretas
RUN chown -R node:node /home/node && \
    mkdir -p /home/node/.n8n && \
    chown -R node:node /home/node/.n8n
  
  USER node
  
# Expõe a porta padrão do n8n (Railway vai usar a variável PORT)
EXPOSE 5678