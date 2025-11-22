FROM ubuntu:20.04

# Evitar prompts interativos durante instalação
ENV DEBIAN_FRONTEND=noninteractive

# Instalar dependências do sistema e bibliotecas gráficas/áudio
RUN apt-get update && apt-get install -y \
    # Dependências principais do ToneLib-GFX
    libcurl4 \
    libfreetype6 \
    libgl1-mesa-glx \
    libgl1-mesa-dri \
    libglu1-mesa \
    # Bibliotecas X11
    libx11-6 \
    libxext6 \
    libxinerama1 \
    libxrandr2 \
    libxcursor1 \
    libxi6 \
    libxrender1 \
    libxfixes3 \
    libxcomposite1 \
    libxdamage1 \
    libxshmfence1 \
    x11-utils \
    # Bibliotecas de áudio (PulseAudio + ALSA)
    libasound2 \
    libasound2-plugins \
    libpulse0 \
    pulseaudio-utils \
    alsa-utils \
    # JACK Audio (para baixa latência)
    jackd2 \
    libjack-jackd2-0 \
    qjackctl \
    pulseaudio-module-jack \
    a2jmidid \
    # Bibliotecas Qt5 (ToneLib usa Qt 5.14+)
    qtbase5-dev \
    libqt5widgets5 \
    libqt5gui5 \
    libqt5core5a \
    libqt5multimedia5 \
    libqt5network5 \
    # Bibliotecas GTK e renderização de texto
    libgtk-3-0 \
    libglib2.0-0 \
    libharfbuzz0b \
    libfribidi0 \
    libpango-1.0-0 \
    libcairo2 \
    # Outras dependências
    ca-certificates \
    fontconfig \
    fonts-dejavu-core \
    fonts-liberation \
    fonts-freefont-ttf \
    && rm -rf /var/lib/apt/lists/*

# Copiar arquivos para o container
COPY ToneLib-GFX-amd64.deb /tmp/
COPY entrypoint.sh /usr/local/bin/

# Instalar o ToneLib-GFX
RUN dpkg -i /tmp/ToneLib-GFX-amd64.deb || true && \
    apt-get update && \
    apt-get -f install -y && \
    rm /tmp/ToneLib-GFX-amd64.deb && \
    rm -rf /var/lib/apt/lists/* && \
    chmod +x /usr/local/bin/entrypoint.sh

# Criar usuário não-root com mesmo UID/GID do host
ARG USER_ID=1000
ARG GROUP_ID=1000
RUN groupadd -g ${GROUP_ID} tonelib && \
    useradd -u ${USER_ID} -g ${GROUP_ID} -G audio -m -s /bin/bash tonelib

# Configurar PulseAudio para cliente
RUN mkdir -p /home/tonelib/.config/pulse && \
    echo "default-server = unix:/run/user/${USER_ID}/pulse/native" > /home/tonelib/.config/pulse/client.conf && \
    chown -R tonelib:tonelib /home/tonelib/.config

USER tonelib
WORKDIR /home/tonelib

# Healthcheck: verifica se o ToneLib está rodando
HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
  CMD pgrep -f "ToneLib" || exit 1

# Script de inicialização inteligente
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD []
