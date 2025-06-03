FROM --platform=$TARGETOS/$TARGETARCH node:18-bookworm-slim

LABEL author="Michael Parker" maintainer="parker@pterodactyl.io"

# add container user and set stop signal
RUN useradd -m -d /home/container container
STOPSIGNAL SIGINT

# Instala dependencias comunes + necesarias para Puppeteer/Chromium
RUN apt update && apt install -y \
    ffmpeg \
    iproute2 \
    git \
    sqlite3 \
    libsqlite3-dev \
    python3 \
    python3-dev \
    ca-certificates \
    dnsutils \
    tzdata \
    zip \
    tar \
    curl \
    build-essential \
    libtool \
    iputils-ping \
    libnss3 \
    tini \
    fonts-liberation \
    libappindicator3-1 \
    libatk-bridge2.0-0 \
    libatk1.0-0 \
    libcups2 \
    libdbus-1-3 \
    libgdk-pixbuf2.0-0 \
    libnspr4 \
    libx11-xcb1 \
    libxcomposite1 \
    libxdamage1 \
    libxrandr2 \
    libasound2t64 \
    xdg-utils \
    --no-install-recommends && \
    apt clean && rm -rf /var/lib/apt/lists/*

# Configura NPM y herramientas modernas
RUN npm install --global npm@10.x.x typescript ts-node @types/node

# Instala pnpm
RUN npm install -g corepack
RUN corepack enable
RUN corepack prepare pnpm@latest --activate

# Configura entorno de ejecución
USER container
ENV USER=container HOME=/home/container
WORKDIR /home/container

COPY --chown=container:container ./../entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/usr/bin/tini", "-g", "--"]
CMD ["/entrypoint.sh"]
