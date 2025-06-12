FROM ubuntu:24.04 as matecat-focal-base-image

# 立即强制替换所有Ubuntu源为TUNA源，绝对不允许任何ubuntu.com
RUN rm -f /etc/apt/sources.list && \
    rm -rf /etc/apt/sources.list.d/* && \
    echo "# TUNA Mirror Sources - FORCED" > /etc/apt/sources.list && \
    echo "deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ noble main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ noble-updates main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ noble-backports main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ noble-security main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "强制验证TUNA源:" && cat /etc/apt/sources.list && \
    find /etc/apt -name "*.list" -exec sed -i 's|http://.*archive.ubuntu.com|https://mirrors.tuna.tsinghua.edu.cn|g' {} \; && \
    find /etc/apt -name "*.list" -exec sed -i 's|http://.*security.ubuntu.com|https://mirrors.tuna.tsinghua.edu.cn|g' {} \; && \
    find /etc/apt -name "*.list" -exec sed -i 's|http://.*ports.ubuntu.com|https://mirrors.tuna.tsinghua.edu.cn|g' {} \; && \
    find /etc/apt -name "*.list" -exec sed -i 's|https://.*archive.ubuntu.com|https://mirrors.tuna.tsinghua.edu.cn|g' {} \; && \
    find /etc/apt -name "*.list" -exec sed -i 's|https://.*security.ubuntu.com|https://mirrors.tuna.tsinghua.edu.cn|g' {} \; && \
    find /etc/apt -name "*.list" -exec sed -i 's|https://.*ports.ubuntu.com|https://mirrors.tuna.tsinghua.edu.cn|g' {} \; && \
    echo "所有源文件检查完成"

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

# 更新包列表（必须从TUNA源）
RUN echo "开始apt-get update，强制从TUNA源下载..." && apt-get update

# 安装基础包
RUN apt-get -y --fix-missing install apt-utils ssh-client vim locate iputils-ping monit git curl wget net-tools tree software-properties-common locales \
    psmisc screen dstat \
    traceroute whois libaio1t64 perl perl-base perl-modules-5.38

# 升级系统
RUN apt-get -y full-upgrade