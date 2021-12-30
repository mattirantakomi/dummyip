FROM ubuntu:20.04

ENV DEBIAN_FRONTEND noninteractive
ENV TZ=Europe/Helsinki
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update && apt-get install -y procps net-tools kmod bind9-utils dnsutils ifupdown curl nano libapache2-mod-php && apt-get clean all
RUN rm -f /var/www/html/index.html
COPY index.php /var/www/html/

COPY conf/mpm_prefork.conf /etc/apache2/mods-available/
COPY conf/servername.conf /etc/apache2/conf-enabled/
COPY conf/php.ini /etc/php/7.4/apache2/

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
