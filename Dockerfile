FROM      ubuntu:14.04
MAINTAINER Jeffery Utter "jeff@jeffutter.com"

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV LC_ALL en_US.UTF-8

RUN locale-gen $LANG \
    && echo "LANG=\"${LANG}\"" > /etc/default/locale \
    && dpkg-reconfigure locales

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y wget \
    && wget -O - http://dl.hhvm.com/conf/hhvm.gpg.key | apt-key add - \
    && echo deb http://dl.hhvm.com/ubuntu trusty main | tee /etc/apt/sources.list.d/hhvm.list \
    && apt-get update \
    && apt-get install -y hhvm-fastcgi nginx \
    && rm -rf /var/lib/apt/lists/*
    
    
# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
	&& ln -sf /dev/stderr /var/log/nginx/error.log

RUN adduser --disabled-login --gecos 'Wordpress' wordpress

RUN cd /home/wordpress \
    && wget http://wordpress.org/latest.tar.gz; tar -xvzf latest.tar.gz \
    && rm latest.tar.gz

EXPOSE 80

ADD nginx/nginx.conf /etc/nginx/nginx.conf
ADD start.sh /start.sh
RUN chmod 755 /start.sh
ADD wordpress/wp-config.php /home/wordpress/
ADD wordpress/production-config.php /home/wordpress/
RUN chown wordpress:wordpress /home/wordpress/*.php

CMD ["/start.sh"]
