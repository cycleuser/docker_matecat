FROM ostico/matecat-focal-base-image:latest

# 设置代理
ENV http_proxy=http://192.168.56.1:7890
ENV https_proxy=http://192.168.56.1:7890
ENV HTTP_PROXY=http://192.168.56.1:7890
ENV HTTPS_PROXY=http://192.168.56.1:7890
ENV no_proxy=localhost,127.0.0.1,::1
ENV NO_PROXY=localhost,127.0.0.1,::1

ENV NODE_RELEASE="20"
ENV PHPDIR="/etc/php/7.4"

RUN export DEBIAN_FRONTEND=noninteractive
RUN ln -fs /usr/share/zoneinfo/Europe/Rome /etc/localtime

# 配置清华tuna源(使用HTTP避免证书问题)
RUN cp /etc/apt/sources.list /etc/apt/sources.list.backup && \
    echo "deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal main restricted universe multiverse" > /etc/apt/sources.list && \
    echo "deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal-updates main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal-backports main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal-security main restricted universe multiverse" >> /etc/apt/sources.list

RUN apt-get update
RUN apt-get -y full-upgrade

RUN locale-gen en_US.UTF-8
ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'

# 配置APT重试和超时设置，分批安装软件包
RUN echo 'Acquire::Retries "3";' > /etc/apt/apt.conf.d/80-retries && \
    echo 'Acquire::http::Timeout "30";' >> /etc/apt/apt.conf.d/80-retries && \
    echo 'Acquire::https::Timeout "30";' >> /etc/apt/apt.conf.d/80-retries

# 分批安装，减少单次下载压力
RUN apt-get update && apt-get -y install apache2 apache2-dev libapache2-mod-php

RUN apt-get -y install php php-xdebug php-json php-xml php-curl php-mysql php-mbstring php-dev php-redis php-zip php-gd

RUN apt-get -y install mysql-client libzip-dev certbot python3-certbot-apache redis-tools

# 直接下载Node.js二进制包安装，避免使用apt安装npm
RUN mkdir -p /opt/nodejs && \
    cd /opt/nodejs && \
    wget https://npmmirror.com/mirrors/node/v16.20.2/node-v16.20.2-linux-x64.tar.gz && \
    tar -zxf node-v16.20.2-linux-x64.tar.gz && \
    ln -s /opt/nodejs/node-v16.20.2-linux-x64/bin/node /usr/local/bin/node && \
    ln -s /opt/nodejs/node-v16.20.2-linux-x64/bin/npm /usr/local/bin/npm && \
    ln -s /opt/nodejs/node-v16.20.2-linux-x64/bin/npx /usr/local/bin/npx && \
    node -v && npm -v

RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Prepare the environment
ENV PHP_POST_MAX_SIZE 1024M
ENV PHP_UPLOAD_MAX_FILESIZE 1024M
ENV PHP_MAX_MEMORY 4096M

ENV SERVICES_DIR "/etc/init.d"
ENV USER_OWNER "www-data"
ENV MATECAT_HOME "/var/www/matecat"

COPY ./app_configs/config.ini /tmp/config.ini
COPY ./app_configs/node_config.ini /tmp/node_config.ini
COPY ./app_configs/Error_Mail_List.ini /tmp/Error_Mail_List.ini

# If you want to enable the login ssystem add your oauth_config.ini taken from Google
#COPY ./app_configs/oauth_config.ini /tmp/oauth_config.ini

COPY ./app_configs/task_manager_config.ini /tmp/task_manager_config.ini

# Apache
RUN mkdir /var/log/apache2/matecat/
RUN rm -rf /etc/apache2/sites-available/default
RUN rm -rf /etc/apache2/sites-enabled/*
RUN userdel www-data
RUN groupadd www-data
RUN useradd -ms /bin/bash -g www-data www-data

RUN sed -i 's/session.save_handler\s*=\s*files/session.save_handler = redis/' ${PHPDIR}/apache2/php.ini
RUN echo 'session.save_path = "tcp://redis:6379?database=15"' >> ${PHPDIR}/apache2/php.ini

## Enable MateCat site
COPY data/ /

RUN a2enmod rewrite filter deflate headers expires proxy_http ssl php7.4 proxy_balancer proxy_wstunnel slotmem_shm
RUN #phpenmod mcrypt

COPY run_plugin_js_build.sh /tmp/run_plugin_js_build.sh
COPY run.sh /tmp/run.sh
RUN chmod +x /tmp/run_plugin_js_build.sh
RUN chmod +x /tmp/run.sh

WORKDIR "/var/www/matecat"
CMD ["/tmp/run.sh"]
