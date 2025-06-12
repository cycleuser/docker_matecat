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

RUN locale-gen en_US.UTF-8
ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'

# 直接强制写入TUNA源
RUN echo "deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ noble main restricted universe multiverse" > /etc/apt/sources.list && \
    echo "deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ noble-updates main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ noble-backports main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ noble-security main restricted universe multiverse" >> /etc/apt/sources.list

# 配置apt重试和超时设置
RUN echo 'Acquire::Retries "3";' >> /etc/apt/apt.conf.d/80-retries && \
    echo 'Acquire::http::Timeout "300";' >> /etc/apt/apt.conf.d/80-retries && \
    echo 'Acquire::https::Timeout "300";' >> /etc/apt/apt.conf.d/80-retries && \
    echo 'Acquire::ftp::Timeout "300";' >> /etc/apt/apt.conf.d/80-retries

RUN apt-get update && apt-get -y full-upgrade && \
    apt-get install -y git software-properties-common && \
    add-apt-repository -y ppa:openjdk-r/ppa && \
    apt-get update && \
    apt-get install -y openjdk-8-jre

COPY data /

COPY startFilter.sh /tmp/startFilter.sh
RUN chmod +x /tmp/startFilter.sh
CMD ["/tmp/startFilter.sh"]
