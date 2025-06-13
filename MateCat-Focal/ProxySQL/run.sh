#!/bin/bash

# 设置代理
export http_proxy=http://192.168.56.1:7890
export https_proxy=http://192.168.56.1:7890
export HTTP_PROXY=http://192.168.56.1:7890
export HTTPS_PROXY=http://192.168.56.1:7890
export no_proxy=localhost,127.0.0.1,::1
export NO_PROXY=localhost,127.0.0.1,::1

echo "=> Waiting for MySQL services to be ready..."

# 首先检查网络连通性
echo "=> Checking network connectivity..."
echo "=> Resolving mysql-master..."
nslookup mysql-master || echo "=> DNS resolution failed for mysql-master"
echo "=> Resolving mysql-slave..."
nslookup mysql-slave || echo "=> DNS resolution failed for mysql-slave"

# 检查端口连通性
echo "=> Checking port connectivity..."
nc -z mysql-master 3306 && echo "=> mysql-master:3306 is reachable" || echo "=> mysql-master:3306 is not reachable"
nc -z mysql-slave 3306 && echo "=> mysql-slave:3306 is reachable" || echo "=> mysql-slave:3306 is not reachable"

# 等待MySQL Master启动
echo "=> Waiting for MySQL Master..."
for i in {120..0}; do
    if mysql -h mysql-master -u admin -padmin -e 'SELECT 1' &> /dev/null; then
        echo "=> MySQL Master is ready"
        break
    fi
    if [ $((i % 10)) -eq 0 ]; then
        echo "=> MySQL Master is starting... ($i seconds remaining)"
        # 每10秒检查一次网络连通性
        nc -z mysql-master 3306 && echo "=> Port 3306 is open" || echo "=> Port 3306 is not open"
    fi
    sleep 1
done

if [ "$i" = 0 ]; then
    echo "=> MySQL Master failed to start within 120 seconds"
    echo "=> Continuing with ProxySQL startup..."
fi

# 等待MySQL Slave启动
echo "=> Waiting for MySQL Slave..."
for i in {120..0}; do
    if mysql -h mysql-slave -u admin -padmin -e 'SELECT 1' &> /dev/null; then
        echo "=> MySQL Slave is ready"
        break
    fi
    if [ $((i % 10)) -eq 0 ]; then
        echo "=> MySQL Slave is starting... ($i seconds remaining)"
        # 每10秒检查一次网络连通性
        nc -z mysql-slave 3306 && echo "=> Port 3306 is open" || echo "=> Port 3306 is not open"
    fi
    sleep 1
done

if [ "$i" = 0 ]; then
    echo "=> MySQL Slave failed to start within 120 seconds"
    echo "=> Continuing with ProxySQL startup..."
fi

echo "Copy configuration file to config dir."
cp /tmp/proxysql.cnf /etc/proxysql.cnf

echo "Kill auto started instance if present."
/etc/init.d/proxysql stop

echo "Clean the database rules"
rm -rf /var/lib/proxysql/*

echo "Executing: ProxySQL"
proxysql -f --idle-threads -c /etc/proxysql.cnf -D /var/lib/proxysql