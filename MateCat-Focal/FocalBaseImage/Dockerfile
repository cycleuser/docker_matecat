FROM registry.cn-hangzhou.aliyuncs.com/acs/ubuntu:20.04 as matecat-focal-base-image

ENV DEBIAN_FRONTEND noninteractive

# 设置代理
ENV http_proxy=http://192.168.56.1:7890
ENV https_proxy=http://192.168.56.1:7890
ENV HTTP_PROXY=http://192.168.56.1:7890
ENV HTTPS_PROXY=http://192.168.56.1:7890
ENV no_proxy=localhost,127.0.0.1,::1
ENV NO_PROXY=localhost,127.0.0.1,::1

# 配置APT重试和超时设置
RUN echo 'Acquire::Retries "3";' > /etc/apt/apt.conf.d/80-retries && \
    echo 'Acquire::http::Timeout "30";' >> /etc/apt/apt.conf.d/80-retries && \
    echo 'Acquire::https::Timeout "30";' >> /etc/apt/apt.conf.d/80-retries

# 备份原始sources.list并配置清华tuna源(使用HTTP避免证书问题)
RUN cp /etc/apt/sources.list /etc/apt/sources.list.backup && \
    echo "deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal main restricted universe multiverse" > /etc/apt/sources.list && \
    echo "deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal-updates main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal-backports main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal-security main restricted universe multiverse" >> /etc/apt/sources.list

RUN apt-get update

# 安装ca-certificates以解决SSL证书问题
RUN apt-get -y install ca-certificates

# 分批安装基础软件包
RUN apt-get -y install apt-utils ssh-client vim locate iputils-ping monit git curl wget net-tools tree

RUN apt-get -y install software-properties-common locales psmisc screen dstat traceroute whois libaio1

RUN apt-get -y install perl perl-base perl-modules

RUN apt-get -y full-upgrade