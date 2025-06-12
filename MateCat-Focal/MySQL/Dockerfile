FROM ostico/matecat-focal-base-image:latest

# 接收构建参数中的代理配置
ARG http_proxy
ARG https_proxy
ARG HTTP_PROXY
ARG HTTPS_PROXY
ARG no_proxy
ARG NO_PROXY
ARG APT_MIRROR=mirrors.tuna.tsinghua.edu.cn

# 设置环境变量以便在容器构建过程中使用代理
ENV http_proxy=${http_proxy}
ENV https_proxy=${https_proxy}
ENV HTTP_PROXY=${HTTP_PROXY}
ENV HTTPS_PROXY=${HTTPS_PROXY}
ENV no_proxy=${no_proxy}
ENV NO_PROXY=${NO_PROXY}

RUN dpkg-divert --local --rename --add /sbin/initctl
RUN ln -snvf /bin/true /sbin/initctl
ENV DEBIAN_FRONTEND noninteractive

# 立即强制替换所有Ubuntu源为TUNA源，绝对不允许任何ubuntu.com
RUN rm -f /etc/apt/sources.list && \
    rm -rf /etc/apt/sources.list.d/* && \
    echo "# TUNA Mirror Sources - FORCED" > /etc/apt/sources.list && \
    echo "deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ noble main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ noble-updates main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ noble-backports main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ noble-security main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "MySQL强制验证TUNA源:" && cat /etc/apt/sources.list && \
    find /etc/apt -name "*.list" -exec sed -i 's|http://.*archive.ubuntu.com|https://mirrors.tuna.tsinghua.edu.cn|g' {} \; && \
    find /etc/apt -name "*.list" -exec sed -i 's|http://.*security.ubuntu.com|https://mirrors.tuna.tsinghua.edu.cn|g' {} \; && \
    find /etc/apt -name "*.list" -exec sed -i 's|http://.*ports.ubuntu.com|https://mirrors.tuna.tsinghua.edu.cn|g' {} \; && \
    find /etc/apt -name "*.list" -exec sed -i 's|https://.*archive.ubuntu.com|https://mirrors.tuna.tsinghua.edu.cn|g' {} \; && \
    find /etc/apt -name "*.list" -exec sed -i 's|https://.*security.ubuntu.com|https://mirrors.tuna.tsinghua.edu.cn|g' {} \; && \
    find /etc/apt -name "*.list" -exec sed -i 's|https://.*ports.ubuntu.com|https://mirrors.tuna.tsinghua.edu.cn|g' {} \; && \
    echo "MySQL所有源文件检查完成"

# 配置apt重试和超时设置
RUN echo 'Acquire::Retries "3";' >> /etc/apt/apt.conf.d/80-retries && \
    echo 'Acquire::http::Timeout "300";' >> /etc/apt/apt.conf.d/80-retries && \
    echo 'Acquire::https::Timeout "300";' >> /etc/apt/apt.conf.d/80-retries && \
    echo 'Acquire::ftp::Timeout "300";' >> /etc/apt/apt.conf.d/80-retries

WORKDIR /tmp

RUN apt-get update
RUN apt-get install -y libev-dev libcurl4-openssl-dev libdbd-mysql-perl rsync gnupg
RUN wget --timeout=300 --tries=3 https://repo.percona.com/apt/percona-release_latest.$(lsb_release -sc)_all.deb && dpkg -i percona-release_latest.$(lsb_release -sc)_all.deb
RUN apt-get update
RUN percona-release enable-only ps-57 && apt-get install -y percona-server-server-5.7
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

