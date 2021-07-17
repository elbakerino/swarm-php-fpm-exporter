FROM alpine:3.13

ARG BUILD_DATE
ARG VCS_REF
ENV VERSION 2.0.2

RUN apk add bind-tools

COPY php-fpm_exporter_${VERSION}_linux_amd64 /php-fpm_exporter

COPY start-fpm-exporter.sh /start-fpm-exporter.sh

RUN chmod +x /start-fpm-exporter.sh

EXPOSE 9253

ENTRYPOINT '/start-fpm-exporter.sh'

LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.name="php-fpm_exporter" \
      org.label-schema.description="A prometheus exporter for PHP-FPM in Swarms." \
      org.label-schema.vcs-url="https://github.com/elbakerino/swarm-php-fpm-exporter" \
      org.label-schema.vendor="elbakerino" \
      org.label-schema.version=$VERSION \
      org.label-schema.schema-version="1.0" \
      org.label-schema.docker.cmd="docker run -it --rm -e PHP_FPM_SCRAPE_URI=\"tasks.<docker-service-name>\" bemit/php-fpm_exporter"
