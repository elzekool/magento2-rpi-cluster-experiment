FROM magento2-rpi/phpfpm-base:60a197a
MAINTAINER Magento2 Boys

COPY magento2 /var/www/magento2

RUN cp /var/www/magento2/app/etc/env.php /var/www/magento2/app/etc/env.org

COPY update-env.php docker-php-entrypoint /usr/local/bin/
