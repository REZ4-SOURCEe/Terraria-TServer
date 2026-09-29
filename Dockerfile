FROM ghcr.io/pryaxis/tshock:v6.2.1

COPY start.sh /start.sh
RUN chmod +x /start.sh

ENTRYPOINT ["/start.sh"]