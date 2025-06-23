#!/bin/bash

# If no config file exists, not installed
if [ ! -f "/var/www/html/config.php" ]; then

    # Create temporary directory & change to it
    TMPDIR=$(mktemp -d -t install_XXX)
    cd ${TMPDIR}

    # Clone the source repository
    git clone ${SOURCE_REPOSITORY} source_repository

    # Copy web base
    cp -rT source_repository/web /var/www/html

    # Remove updater
    rm -Rfv /var/www/html/updater

    # Install Database
    if [ "${INSTALL_DATABASE}" == "true" ]; then
        # Wait for database to become available
        while ! mysqladmin ping --host="${DB_HOST}" --user="${DB_USERNAME}" --password="${DB_PASSWORD}" --silent; do
            echo 'Waiting for database to come up...'
            sleep 2
        done
        # Check if database is already installed
        if [  $(mysql -N -s --host=${DB_HOST} --user=${DB_USERNAME} --password=${DB_PASSWORD} -e \
            "select count(*) from information_schema.tables where \
                table_schema='${DB_NAME}' and table_name='hlstats_Servers';") -eq 1 ]; then
            echo 'Database is already filled'
        else
            echo 'Importing database tables'
            mysql --host=${DB_HOST} --user=${DB_USERNAME} --password=${DB_PASSWORD} ${DB_NAME} < sql/install.sql
        fi
    fi

    # Clean up temporary direvtory
    cd / && rm -Rfv ${TMPDIR}
fi

# Set config variables for database
sed -i "/DB_NAME/s/\"\([^\"]*\)\"/\"${DB_NAME}\"/2g" /var/www/html/config.php
sed -i "/DB_USER/s/\"\([^\"]*\)\"/\"${DB_USERNAME}\"/2g" /var/www/html/config.php
sed -i "/DB_PASS/s/\"\([^\"]*\)\"/\"${DB_PASSWORD}\"/2g" /var/www/html/config.php
sed -i "/DB_ADDR/s/\"\([^\"]*\)\"/\"${DB_HOST}\"/2g" /var/www/html/config.php

exec "docker-php-entrypoint" $@
