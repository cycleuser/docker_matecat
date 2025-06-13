#!/bin/bash

# 设置代理
export http_proxy=http://192.168.56.1:7890
export https_proxy=http://192.168.56.1:7890
export HTTP_PROXY=http://192.168.56.1:7890
export HTTPS_PROXY=http://192.168.56.1:7890
export no_proxy=localhost,127.0.0.1,::1
export NO_PROXY=localhost,127.0.0.1,::1

# 创建必要的目录
mkdir -p /var/run/mysqld
mkdir -p /var/log/mysql
mkdir -p /var/lib/mysql-files/binlog

# 设置正确的权限
chown -R mysql:mysql /var/lib/mysql/
chown -R mysql:mysql /var/run/mysqld/
chown -R mysql:mysql /var/log/mysql/
chown -R mysql:mysql /var/lib/mysql-files/

# 清理旧的pid文件
rm -rf /var/run/mysqld/mysqld.pid 2>/dev/null

# 检查数据库是否已初始化
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "=> Initializing MySQL database..."
    mysqld --initialize-insecure --user=mysql --datadir=/var/lib/mysql
fi

echo "=> Starting MySQL service..."
echo "Executing: mysqld --basedir=/usr --datadir=/var/lib/mysql --plugin-dir=/usr/lib/mysql/plugin --log-error=/var/log/mysql/error.log --open-files-limit=65535 --pid-file=/var/run/mysqld/mysqld.pid --socket=/var/run/mysqld/mysqld.sock --port=3306"

# 启动MySQL服务
service mysql start

# 等待MySQL服务启动
echo "=> Waiting for MySQL to start..."
for i in {30..0}; do
    if mysql -e 'SELECT 1' &> /dev/null; then
        break
    fi
    echo "=> MySQL is starting... ($i seconds remaining)"
    sleep 1
done

if [ "$i" = 0 ]; then
    echo "=> MySQL failed to start"
    exit 1
fi

echo "=> MySQL started successfully"

# Create users on master and slave if they do not exist
/bin/bash /tmp/create_mysql_admin_user.sh || exit 1

# Now check for matecat db, if the db do not exists and master has no GTID, the replication is not in place
MATECAT_EXISTS=$(mysql -e "SHOW DATABASES LIKE 'matecat%'")
if [[ -z "${MATECAT_EXISTS}" && "${_type_}" == "master" ]]; then

  # Get the master GTID
  mysql -e "CREATE DATABASE test;"
  mysql -e "DROP DATABASE test;"

  MYSQL_MASTER_GTID=$(mysql -e "SHOW MASTER STATUS\G" | grep -i "Executed_Gtid_Set:" | awk '{print $2}')
  printf "*** MYSQL_MASTER_GTID: %s \n\n" "${MYSQL_MASTER_GTID}"

  RET=1
  while [[ RET -ne 0 ]] && [[ "$MYSQL_SLAVE_REPLICATION_RUNNING" != "$MYSQL_MASTER_GTID" ]]; do

    echo "=> Waiting for confirmation of MySQL Slave ready"
    MYSQL_SLAVE_REPLICATION_RUNNING=$(mysql -uadmin -padmin -h mysql-slave -e "SHOW SLAVE STATUS\G" | grep -i "Executed_Gtid_Set:" | awk '{print $2}' | sed 's/,$//g')
    printf "*** MYSQL_SLAVE_EXECUTED_GTID: %s \n\n" "${MYSQL_SLAVE_REPLICATION_RUNNING}"

    if [[ -n "${MYSQL_SLAVE_REPLICATION_RUNNING}" ]]; then
      RET=0
    fi

    sleep 2

  done

  # MySql MateCat
  # 使用gitee镜像替代github
git clone https://gitee.com/mirrors/matecat.git /tmp/matecat || \
git clone https://github.com.cnpmjs.org/matecat/MateCat.git /tmp/matecat || \
git clone https://hub.fastgit.xyz/matecat/MateCat.git /tmp/matecat || \
git clone https://github.com/matecat/MateCat.git /tmp/matecat

  # Creating schema and fill some data
  echo "Executing: /usr/bin/mysql </tmp/matecat/lib/Model/matecat.sql"
  /usr/bin/mysql </tmp/matecat/lib/Model/matecat.sql
  # clean
  rm -rf /tmp/matecat

elif [[ -z "${MATECAT_EXISTS}" && "${_type_}" == "slave" ]]; then

  RET=1
  while [[ RET -ne 0 ]]; do

    echo "=> Waiting for confirmation of MySQL Master ready"
    MYSQL_MASTER_GTID=$(mysql -uadmin -padmin -h mysql-master -e "SHOW MASTER STATUS\G" | grep -i "Executed_Gtid_Set:" | awk '{print $2}')
    printf "*** MYSQL_MASTER_GTID: %s \n\n" "${MYSQL_MASTER_GTID}"

    if [[ -n "${MYSQL_MASTER_GTID}" ]]; then
      RET=0
    fi

    sleep 2

  done

  #Set Replication
  echo "#Set Replication"
  mysql -e "RESET MASTER"
  mysql -e "STOP SLAVE; RESET SLAVE ALL;"
  mysql -e "SET GLOBAL gtid_purged=\"${MYSQL_MASTER_GTID}\" ;"
  mysql -e "CHANGE MASTER TO MASTER_HOST=\"mysql-master\", MASTER_USER=\"admin\", MASTER_PASSWORD=\"admin\", MASTER_AUTO_POSITION = 1; START SLAVE;"

  sleep 1
  SLAVE_STATUS=$(mysql -e "SHOW SLAVE STATUS \G")
  printf "%s \n\n" "${SLAVE_STATUS}"

fi

while true; do
  #    echo date " => Waiting for an infinite. More or less..."
  sleep 5
done
