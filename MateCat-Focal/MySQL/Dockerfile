FROM ostico/matecat-focal-base-image:latest

# 设置代理
ENV http_proxy=http://192.168.56.1:7890
ENV https_proxy=http://192.168.56.1:7890
ENV HTTP_PROXY=http://192.168.56.1:7890
ENV HTTPS_PROXY=http://192.168.56.1:7890
ENV no_proxy=localhost,127.0.0.1,::1
ENV NO_PROXY=localhost,127.0.0.1,::1

RUN dpkg-divert --local --rename --add /sbin/initctl
RUN ln -snvf /bin/true /sbin/initctl
ENV DEBIAN_FRONTEND noninteractive

WORKDIR /tmp

# 配置APT重试和超时设置
RUN echo 'Acquire::Retries "3";' > /etc/apt/apt.conf.d/80-retries && \
    echo 'Acquire::http::Timeout "30";' >> /etc/apt/apt.conf.d/80-retries && \
    echo 'Acquire::https::Timeout "30";' >> /etc/apt/apt.conf.d/80-retries

# 配置清华tuna源(使用HTTP避免证书问题)
RUN cp /etc/apt/sources.list /etc/apt/sources.list.backup && \
    echo "deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal main restricted universe multiverse" > /etc/apt/sources.list && \
    echo "deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal-updates main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal-backports main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal-security main restricted universe multiverse" >> /etc/apt/sources.list

RUN apt-get update

# 分批安装依赖包
RUN apt-get install -y libev4 libcurl4-openssl-dev libdbd-mysql-perl rsync gnupg2

# 使用Ubuntu官方的MySQL服务器，避免Percona的复杂配置
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y mysql-server mysql-client

# 如果需要特定的MySQL 5.7版本，可以指定
# RUN DEBIAN_FRONTEND=noninteractive apt-get install -y mysql-server-5.7 mysql-client-5.7
RUN apt-get -y full-upgrade

# 停止MySQL服务（如果正在运行）并清理
RUN service mysql stop || true && \
    rm -rf /var/lib/mysql/* && \
    rm -rf /var/run/mysqld/* && \
    rm -rf /var/log/mysql/*

#RUN wget https://www.percona.com/downloads/Percona-XtraBackup-2.4/Percona-XtraBackup-2.4.15/binary/debian/bionic/x86_64/percona-xtrabackup-24_2.4.15-1.bionic_amd64.deb
#RUN dpkg -i percona-xtrabackup-24_2.4.15-1.bionic_amd64.deb

COPY run.sh /tmp/run.sh
RUN chmod +x /tmp/run.sh

# 创建必要的目录并设置权限
RUN mkdir -p /var/lib/mysql-files/binlog && \
    mkdir -p /var/run/mysqld && \
    mkdir -p /var/log/mysql && \
    chown -R mysql:mysql /var/lib/mysql && \
    chown -R mysql:mysql /var/lib/mysql-files && \
    chown -R mysql:mysql /var/run/mysqld && \
    chown -R mysql:mysql /var/log/mysql

ARG _type_
ENV _type_=$_type_
ENV MYSQL_PASS "admin"

COPY my-${_type_}.cnf /etc/mysql/my.cnf
RUN chown mysql:mysql /etc/mysql/my.cnf
RUN chmod 660 /etc/mysql/my.cnf

COPY create_mysql_admin_user.sh /tmp/create_mysql_admin_user.sh
RUN chmod +x /tmp/create_mysql_admin_user.sh

RUN rm -rf /var/lib/mysql/auto.cnf

VOLUME ["/var/lib/mysql/"]

CMD ["/tmp/run.sh"]

