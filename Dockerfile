FROM wordpress:cli

COPY --chmod=0755 wpcli-entrypoint.sh /usr/local/bin/wpcli-entrypoint.sh

ENTRYPOINT ["wpcli-entrypoint.sh"]
CMD ["tail", "-f", "/dev/null"]
