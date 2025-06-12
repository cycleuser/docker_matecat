FROM ostico/matecat-focal-base-image:latest

# 设置代理
ENV http_proxy=http://192.168.56.1:7890
ENV https_proxy=http://192.168.56.1:7890
ENV HTTP_PROXY=http://192.168.56.1:7890
ENV HTTPS_PROXY=http://192.168.56.1:7890
ENV no_proxy=localhost,127.0.0.1,::1
ENV NO_PROXY=localhost,127.0.0.1,::1

ARG AMQ_VERSION=5.19.0

RUN locale-gen en_US.UTF-8
ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'

ENV JAVA_OPTS '-Xmx256M'
RUN dpkg-divert --local --rename --add /sbin/initctl
RUN ln -snvf /bin/true /sbin/initctl
ENV DEBIAN_FRONTEND noninteractive

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

RUN apt-get update && apt-get -y full-upgrade

# 分批安装软件包
RUN apt-get install -y software-properties-common openjdk-8-jre

# 下载ActiveMQ
RUN \
    cd /tmp/ && \
    wget --no-check-certificate https://mirrors.tuna.tsinghua.edu.cn/apache/activemq/${AMQ_VERSION}/apache-activemq-${AMQ_VERSION}-bin.tar.gz || \
    wget --no-check-certificate https://mirrors.aliyun.com/apache/activemq/${AMQ_VERSION}/apache-activemq-${AMQ_VERSION}-bin.tar.gz || \
    wget --no-check-certificate https://archive.apache.org/dist/activemq/${AMQ_VERSION}/apache-activemq-${AMQ_VERSION}-bin.tar.gz && \
    tar xzf apache-activemq-${AMQ_VERSION}-bin.tar.gz && rm apache-activemq-${AMQ_VERSION}-bin.tar.gz && \
    mv apache-activemq-${AMQ_VERSION} /opt && \
    ln -sf /opt/apache-activemq-${AMQ_VERSION}/ /opt/activemq && \
    adduser -system activemq && \
    sed -i "s#activemq:/bin/false#activemq:/bin/bash#g" /etc/passwd && \
    chown -R activemq: /opt/apache-activemq-${AMQ_VERSION}/ && \
    ln -sf /opt/activemq/bin/activemq /etc/init.d/

COPY installActivemq.sh /tmp/installActivemq.sh
RUN chmod +x /tmp/installActivemq.sh

CMD ["/tmp/installActivemq.sh"]