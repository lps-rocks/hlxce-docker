FROM php:8.1-apache

ENV DB_NAME=hlxce \
    DB_USERNAME=hlxce \
    DB_PASSWORD=hlxce \
    DB_HOST=db \
    UPDATE_DB=false \
    SOURCE_REPOSITORY=https://github.com/lps-rocks/hlstatsx-community-edition.git

COPY entrypoint.sh /entrypoint.sh
COPY hlxce.ini /usr/local/etc/php/conf.d/

RUN apt-get update && apt-get -y install git sed libfreetype6-dev libjpeg62-turbo-dev libpng-dev zlib1g zlib1g-dev --no-install-recommends \
        && rm -rf /var/lib/apt/lists/* \
        && docker-php-ext-configure gd --with-freetype --with-jpeg \
        && docker-php-ext-install gd mysqli \
        && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false git \
        && chmod +x /entrypoint.sh

EXPOSE 80/tcp

VOLUME ["/var/www/html"]

ENTRYPOINT ["/entrypoint.sh"]

CMD ["apache2-foreground"]
