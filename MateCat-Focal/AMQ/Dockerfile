FROM ostico/matecat-focal-base-image:latest

# 设置代理
ENV http_proxy=http://192.168.254.242:7890
ENV https_proxy=http://192.168.254.242:7890
ENV HTTP_PROXY=http://192.168.254.242:7890
ENV HTTPS_PROXY=http://192.168.254.242:7890
ENV no_proxy=localhost,127.0.0.1,::1
ENV NO_PROXY=localhost,127.0.0.1,::1

ARG AMQ_VERSION=5.15.10

RUN locale-gen en_US.UTF-8
ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'

ENV JAVA_OPTS '-Xmx256M'
RUN dpkg-divert --local --rename --add /sbin/initctl
RUN ln -snvf /bin/true /sbin/initctl
ENV DEBIAN_FRONTEND noninteractive

# 配置清华tuna源(使用HTTP避免证书问题)
RUN cp /etc/apt/sources.list /etc/apt/sources.list.backup && \
    echo "deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal main restricted universe multiverse" > /etc/apt/sources.list && \
    echo "deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal-updates main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal-backports main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal-security main restricted universe multiverse" >> /etc/apt/sources.list

RUN apt-get update && apt-get -y full-upgrade && apt-get install -y software-properties-common && \
    add-apt-repository -y ppa:openjdk-r/ppa && \
    apt-get update && \
    apt-get install -y  openjdk-8-jre && \
    cd /tmp/ && \
    wget http://archive.apache.org/dist/activemq/5.15.10/apache-activemq-${AMQ_VERSION}-bin.tar.gz && \
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