FROM ubuntu:24.04 as matecat-focal-base-image

# 立即替换sources.list为TUNA源，不能让apt使用默认源
RUN cp /etc/apt/sources.list /etc/apt/sources.list.bak && \
    echo "# TUNA Mirror Sources - Forced Override" > /etc/apt/sources.list && \
    echo "deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ noble main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ noble-updates main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ noble-backports main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ noble-security main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "验证sources.list内容:" && cat /etc/apt/sources.list

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

ENV DEBIAN_FRONTEND=noninteractive

# 配置apt重试和超时设置
RUN echo 'Acquire::Retries "3";' >> /etc/apt/apt.conf.d/80-retries && \
    echo 'Acquire::http::Timeout "300";' >> /etc/apt/apt.conf.d/80-retries && \
    echo 'Acquire::https::Timeout "300";' >> /etc/apt/apt.conf.d/80-retries && \
    echo 'Acquire::ftp::Timeout "300";' >> /etc/apt/apt.conf.d/80-retries

# 更新包列表（应该从TUNA源）
RUN echo "开始apt-get update，应该从TUNA源下载..." && apt-get update

# 安装基础包
RUN apt-get -y --fix-missing install apt-utils ssh-client vim locate iputils-ping monit git curl wget net-tools tree software-properties-common locales \
    psmisc screen dstat \
    traceroute whois libaio1t64 perl perl-base perl-modules-5.38

# 升级系统
RUN apt-get -y full-upgrade