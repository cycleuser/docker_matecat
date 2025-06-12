FROM ostico/matecat-focal-base-image:latest

# 设置代理
ENV http_proxy=http://192.168.254.242:7890
ENV https_proxy=http://192.168.254.242:7890
ENV HTTP_PROXY=http://192.168.254.242:7890
ENV HTTPS_PROXY=http://192.168.254.242:7890
ENV no_proxy=localhost,127.0.0.1,::1
ENV NO_PROXY=localhost,127.0.0.1,::1

RUN dpkg-divert --local --rename --add /sbin/initctl
RUN ln -snvf /bin/true /sbin/initctl
ENV DEBIAN_FRONTEND noninteractive

WORKDIR /tmp

# 配置清华tuna源(使用HTTP避免证书问题)
RUN cp /etc/apt/sources.list /etc/apt/sources.list.backup && \
    echo "deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal main restricted universe multiverse" > /etc/apt/sources.list && \
    echo "deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal-updates main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal-backports main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal-security main restricted universe multiverse" >> /etc/apt/sources.list

RUN apt-get update
RUN apt-get install -y libev4 libcurl4-openssl-dev libdbd-mysql-perl rsync gnupg2

# 使用MySQL官方包而不是Percona，避免源的问题
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y mysql-server-8.0 mysql-client-8.0

# 或者如果需要使用Percona，配置清华源
# RUN wget http://mirrors.tuna.tsinghua.edu.cn/percona/apt/percona-release_latest.$(lsb_release -sc)_all.deb && dpkg -i percona-release_latest.$(lsb_release -sc)_all.deb
# RUN sed -i 's|repo.percona.com|mirrors.tuna.tsinghua.edu.cn/percona|g' /etc/apt/sources.list.d/percona-*.list
# RUN apt-get update
# RUN percona-release enable-only ps-57 && apt-get install -y percona-server-server-5.7
RUN apt-get -y full-upgrade

#RUN wget https://www.percona.com/downloads/Percona-XtraBackup-2.4/Percona-XtraBackup-2.4.15/binary/debian/bionic/x86_64/percona-xtrabackup-24_2.4.15-1.bionic_amd64.deb
#RUN dpkg -i percona-xtrabackup-24_2.4.15-1.bionic_amd64.deb

COPY run.sh /tmp/run.sh
RUN chmod +x /tmp/run.sh

RUN mkdir -p /var/lib/mysql-files/binlog
RUN chown -R mysql:mysql /var/lib/mysql-files/binlog

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

