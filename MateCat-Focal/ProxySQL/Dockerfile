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
RUN export DEBIAN_FRONTEND=noninteractive

# 配置清华tuna源(使用HTTP避免证书问题)
RUN cp /etc/apt/sources.list /etc/apt/sources.list.backup && \
    echo "deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal main restricted universe multiverse" > /etc/apt/sources.list && \
    echo "deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal-updates main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal-backports main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal-security main restricted universe multiverse" >> /etc/apt/sources.list

RUN apt-get update && apt-get -y full-upgrade && \
    apt -y install vim locate iputils-ping curl wget net-tools \
    mysql-client psmisc screen dstat \
    traceroute whois libaio1 perl perl-base perl-modules

WORKDIR /tmp

# 直接安装ProxySQL，避免从GitHub下载
RUN apt-get update && \
    apt-get install -y --no-install-recommends gnupg2 lsb-release && \
    echo "deb http://mirrors.tuna.tsinghua.edu.cn/proxysql/deb/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/proxysql.list && \
    echo "deb http://mirrors.aliyun.com/proxysql/deb/ $(lsb_release -sc) main" >> /etc/apt/sources.list.d/proxysql.list && \
    apt-get update && \
    apt-get install -y proxysql || \
    apt-get install -y --allow-unauthenticated proxysql

COPY proxysql.cnf /tmp/proxysql.cnf

COPY run.sh /tmp/run.sh
RUN chmod +x /tmp/run.sh

CMD ["/tmp/run.sh"]