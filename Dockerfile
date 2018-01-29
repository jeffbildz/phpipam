FROM ubuntu:xenial 


RUN DEBIAN_FRONTEND=noninteractive apt-get update \
                                && apt-get -y install apache2 libapache2-mod-php7.0 php7.0-mysql vim curl php7.0-gmp php7.0-ldap php-pear \
                                && apt-get clean 
                                

ADD https://github.com/phpipam/phpipam/archive/master.tar.gz /tmp
RUN tar -xzf /tmp/master.tar.gz -C /var/www/html --strip-components=1

#COPY config.php /var/www/html

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
            org.label-schema.url="https://rafpe.ninja" \
            org.label-schema.vcs-ref="d7ef28d" \
            org.label-schema.vcs-type="Git" \
            org.label-schema.vcs-url="https://github.com/jeffbildz/phpipam.git"


EXPOSE 80 443

CMD ["/usr/sbin/apache2", "-D", "FOREGROUND"]
