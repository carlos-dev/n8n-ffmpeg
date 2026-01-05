FROM n8nio/n8n:latest

USER root

# Instala ffmpeg (Alpine usa apk)
RUN apk add --no-cache ffmpeg

# Verifica se o ffmpeg está instalado e funcionando
RUN ffmpeg -version

USER node