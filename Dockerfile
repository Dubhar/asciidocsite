FROM nginx:1.25.0-alpine3.17

# Install needed software
RUN apk add --no-cache openssh-client git asciidoctor rsync supervisor

# Setup automatic website updates via git
COPY update.sh /etc/periodic/15min/update
RUN chmod +x /etc/periodic/15min/update

# Setup supervisor to start cron and nginx
COPY ./supervisord.conf /etc/supervisor/conf.d/supervisord.conf
ENTRYPOINT ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
