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
        $DOWNLOAD_CMD https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-${ARCH}-static.tar.xz -O /tmp/ffmpeg.tar.xz && \
        tar xf /tmp/ffmpeg.tar.xz -C /tmp && \
        cp /tmp/ffmpeg-*-static/ffmpeg /usr/local/bin/ && \
        cp /tmp/ffmpeg-*-static/ffprobe /usr/local/bin/ && \
        chmod +x /usr/local/bin/ffmpeg /usr/local/bin/ffprobe && \
        rm -rf /tmp/ffmpeg-* /tmp/ffmpeg.tar.xz; \
    fi

# Verifica se o ffmpeg está instalado
RUN ffmpeg -version || (echo "ERRO: ffmpeg não foi instalado corretamente" && exit 1)

USER node