FROM ubuntu:xenial 

ENV PHPIPAM_SOURCE https://github.com/phpipam/phpipam/archive/
ENV PHPIPAM_VERSION 1.3.1
ENV WEB_REPO /var/www/html

# Install required deb packages
RUN apt-get update && apt-get -y upgrade && \
    apt-get install -y php-pear php5-curl php5-mysql php5-json php5-gmp php5-mcrypt php5-ldap php5-gd php-net-socket libgmp-dev libmcrypt-dev libpng12-dev libfreetype6-dev libjpeg-dev libpng-dev libldap2-dev && \
    rm -rf /var/lib/apt/lists/*

# Configure apache and required PHP modules
RUN docker-php-ext-configure mysqli --with-mysqli=mysqlnd && \
    docker-php-ext-install mysqli && \
    docker-php-ext-configure gd --enable-gd-native-ttf --with-freetype-dir=/usr/include/freetype2 --with-png-dir=/usr/include --with-jpeg-dir=/usr/include && \
    docker-php-ext-install gd && \
    docker-php-ext-install sockets && \
    docker-php-ext-install pdo_mysql && \
    docker-php-ext-install gettext && \
    ln -s /usr/include/x86_64-linux-gnu/gmp.h /usr/include/gmp.h && \
    docker-php-ext-configure gmp --with-gmp=/usr/include/x86_64-linux-gnu && \
    docker-php-ext-install gmp && \
    docker-php-ext-install mcrypt && \
    docker-php-ext-install pcntl && \
    docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu && \
    docker-php-ext-install ldap && \
    echo ". /etc/environment" >> /etc/apache2/envvars && \
    a2enmod rewrite

COPY php.ini /usr/local/etc/php/

# copy phpipam sources to web dir
ADD ${PHPIPAM_SOURCE}/${PHPIPAM_VERSION}.tar.gz /tmp/
RUN tar -xzf /tmp/${PHPIPAM_VERSION}.tar.gz -C ${WEB_REPO}/ --strip-components=1

ADD docker_files/000-default.conf /etc/apache2/sites-available/ 
ADD docker_files/config.php /var/www/html/ 


VOLUME ["/ssl"]

RUN a2enmod rewrite

# apache env vars
ENV APACHE_LOCK_DIR /var/lock
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2/
ENV APACHE_PID_FILE /var/apache.pid

# Defaults
ENV SSL_ENABLED false
ENV PROXY_ENABLED false

LABEL org.label-schema.build-date="2018-01-29T10:05:01Z" \
            org.label-schema.docker.dockerfile="/Dockerfile" \
            org.label-schema.license="MIT" \
            org.label-schema.name="PHPIpam" \
            org.label-schema.url="https://github.com/jeffbildz" \
            org.label-schema.vcs-ref="d7ef28d" \
            org.label-schema.vcs-type="Git" \
            org.label-schema.vcs-url="https://github.com/jeffbildz/phpipam.git"


EXPOSE 80 443
