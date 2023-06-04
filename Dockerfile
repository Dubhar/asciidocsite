FROM nginx:1.25.0-alpine3.17

# Install needed software
RUN apk add --no-cache openssh-client git asciidoctor rsync supervisor

# Setup automatic website updates via git
COPY update.sh /etc/periodic/daily/update
RUN chmod +x /etc/periodic/daily/update
RUN crontab -l | { cat; echo "@reboot /etc/periodic/daily/update"; } | crontab -

# Setup supervisor to start cron and nginx
COPY ./supervisord.conf /etc/supervisor/conf.d/supervisord.conf
ENTRYPOINT ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
