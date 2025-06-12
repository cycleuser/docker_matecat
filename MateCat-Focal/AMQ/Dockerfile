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

ARG AMQ_VERSION=5.15.10

RUN locale-gen en_US.UTF-8
ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'

ENV JAVA_OPTS '-Xmx256M'
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
    echo "AMQ强制验证TUNA源:" && cat /etc/apt/sources.list && \
    find /etc/apt -name "*.list" -exec sed -i 's|http://.*archive.ubuntu.com|https://mirrors.tuna.tsinghua.edu.cn|g' {} \; && \
    find /etc/apt -name "*.list" -exec sed -i 's|http://.*security.ubuntu.com|https://mirrors.tuna.tsinghua.edu.cn|g' {} \; && \
    find /etc/apt -name "*.list" -exec sed -i 's|http://.*ports.ubuntu.com|https://mirrors.tuna.tsinghua.edu.cn|g' {} \; && \
    find /etc/apt -name "*.list" -exec sed -i 's|https://.*archive.ubuntu.com|https://mirrors.tuna.tsinghua.edu.cn|g' {} \; && \
    find /etc/apt -name "*.list" -exec sed -i 's|https://.*security.ubuntu.com|https://mirrors.tuna.tsinghua.edu.cn|g' {} \; && \
    find /etc/apt -name "*.list" -exec sed -i 's|https://.*ports.ubuntu.com|https://mirrors.tuna.tsinghua.edu.cn|g' {} \; && \
    echo "AMQ所有源文件检查完成"

# 配置apt重试和超时设置
RUN echo 'Acquire::Retries "3";' >> /etc/apt/apt.conf.d/80-retries && \
    echo 'Acquire::http::Timeout "300";' >> /etc/apt/apt.conf.d/80-retries && \
    echo 'Acquire::https::Timeout "300";' >> /etc/apt/apt.conf.d/80-retries && \
    echo 'Acquire::ftp::Timeout "300";' >> /etc/apt/apt.conf.d/80-retries

RUN apt-get update && apt-get -y full-upgrade && apt-get install -y software-properties-common && \
    add-apt-repository -y ppa:openjdk-r/ppa && \
    apt-get update && \
    (apt-get install -y openjdk-8-jre || apt-get install -y --fix-missing openjdk-8-jre) && \
    cd /tmp/ && \
    wget --timeout=300 --tries=3 http://archive.apache.org/dist/activemq/5.15.10/apache-activemq-${AMQ_VERSION}-bin.tar.gz && \
    tar xzf apache-activemq-${AMQ_VERSION}-bin.tar.gz && rm apache-activemq-${AMQ_VERSION}-bin.tar.gz && \
    mv apache-activemq-${AMQ_VERSION} /opt && \
    ln -sf /opt/apache-activemq-${AMQ_VERSION}/ /opt/activemq && \
    adduser --system activemq && \
    sed -i "s#activemq:/bin/false#activemq:/bin/bash#g" /etc/passwd && \
    chown -R activemq: /opt/apache-activemq-${AMQ_VERSION}/ && \
    ln -sf /opt/activemq/bin/activemq /etc/init.d/

COPY installActivemq.sh /tmp/installActivemq.sh
RUN chmod +x /tmp/installActivemq.sh

CMD ["/tmp/installActivemq.sh"]