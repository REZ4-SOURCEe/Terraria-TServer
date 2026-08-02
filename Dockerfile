FROM ryshe/terraria:tshock-1.4.5.6-6.1.0

COPY start.sh /start.sh
RUN chmod +x /start.sh

ENTRYPOINT ["/start.sh"]
