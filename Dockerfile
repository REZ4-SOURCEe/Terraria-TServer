FROM mcr.microsoft.com/dotnet/runtime:9.0

WORKDIR /tshock

RUN apt-get update && \
    apt-get install -y wget unzip ca-certificates && \
    rm -rf /var/lib/apt/lists/*

RUN wget -O /tmp/tshock.zip \
    "https://github.com/Pryaxis/TShock/releases/download/v6.2.1/TShock-6.2.1-for-Terraria-1.4.5.8-linux-x64-Release.zip" && \
    unzip /tmp/tshock.zip -d /tshock && \
    rm /tmp/tshock.zip

COPY start.sh /start.sh
RUN chmod +x /start.sh

ENTRYPOINT ["/start.sh"]