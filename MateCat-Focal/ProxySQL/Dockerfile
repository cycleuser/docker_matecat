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
RUN export DEBIAN_FRONTEND=noninteractive

# 强制使用TUNA源
ARG TUNA_SOURCES
RUN echo "${TUNA_SOURCES}" > /etc/apt/sources.list

# 配置apt重试和超时设置
RUN echo 'Acquire::Retries "3";' >> /etc/apt/apt.conf.d/80-retries && \
    echo 'Acquire::http::Timeout "300";' >> /etc/apt/apt.conf.d/80-retries && \
    echo 'Acquire::https::Timeout "300";' >> /etc/apt/apt.conf.d/80-retries && \
    echo 'Acquire::ftp::Timeout "300";' >> /etc/apt/apt.conf.d/80-retries

RUN apt-get update && apt-get -y full-upgrade && \
    apt -y install vim locate iputils-ping curl wget net-tools \
    mysql-client psmisc screen dstat \
    traceroute whois libaio1t64 perl perl-base perl-modules-5.38

WORKDIR /tmp
RUN wget --timeout=300 --tries=3 https://github.com/sysown/proxysql/releases/download/v2.0.2/proxysql_2.0.2-dbg-ubuntu16_amd64.deb
RUN dpkg -i proxysql_2.0.2-dbg-ubuntu16_amd64.deb

COPY proxysql.cnf /tmp/proxysql.cnf

COPY run.sh /tmp/run.sh
RUN chmod +x /tmp/run.sh

CMD ["/tmp/run.sh"]