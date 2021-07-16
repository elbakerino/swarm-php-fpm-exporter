#!/bin/sh

export PHP_FPM_SCRAPE_URI="$(dig +short $SCRAPE_SERVICE | sed 's/.*/tcp:\/\/&:9000\/status/' | paste -d ','  - - | sed 's/,$//')"

echo "Starting server with PHP_FPM_SCRAPE_URI: ${PHP_FPM_SCRAPE_URI}"

/php-fpm_exporter server
