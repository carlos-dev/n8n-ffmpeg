# -------- STAGE 1: imagem com ffmpeg --------
  FROM jrottenberg/ffmpeg:6.1-alpine AS ffmpeg

  # -------- STAGE 2: n8n --------
  FROM n8nio/n8n:latest
  
  USER root
  
  # Copia o ffmpeg binário para o container do n8n
  COPY --from=ffmpeg /usr/local/bin/ffmpeg /usr/local/bin/ffmpeg
  
  # (opcional) copiar ffprobe também
  COPY --from=ffmpeg /usr/local/bin/ffprobe /usr/local/bin/ffprobe
  
  USER node
  