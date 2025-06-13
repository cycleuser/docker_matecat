#!/bin/bash

RET=1
while [[ RET -ne 0 ]]; do
    echo "=> Waiting for confirmation of MySQL service startup"
    sleep 5
    mysql -e "status" # > /dev/null 2>&1
    RET=$?
done

ADM_ACCOUNT=$(mysql -e "SELECT * FROM mysql.user WHERE User = 'admin'")
if [[ -n "${ADM_ACCOUNT}" ]]; then
    exit 0
fi

#PASS=${MYSQL_PASS:-$(pwgen -s 12 1)}
PASS=${MYSQL_PASS}
_word=$( [ "${MYSQL_PASS}" ] && echo "preset" || echo "random" )
echo "=> Creating MySQL admin user with ${_word} password"

# 创建admin用户，如果已存在则跳过
mysql -e "CREATE USER IF NOT EXISTS 'admin'@'%' IDENTIFIED BY '$PASS'"
mysql -e "GRANT ALL PRIVILEGES ON *.* TO 'admin'@'%' WITH GRANT OPTION"

# 创建matecat用户，ProxySQL配置中需要
mysql -e "CREATE USER IF NOT EXISTS 'matecat'@'%' IDENTIFIED BY 'matecat01'"
mysql -e "GRANT ALL PRIVILEGES ON *.* TO 'matecat'@'%' WITH GRANT OPTION"

mysql -e "FLUSH PRIVILEGES"

# 验证用户创建
echo "=> Verifying users created:"
mysql -e "SELECT User, Host FROM mysql.user WHERE User IN ('admin', 'matecat')"


echo "=> Done!"

echo "========================================================================"
echo "You can now connect to this MySQL Server using:"
echo ""
echo "    mysql -uadmin -p$PASS -h<host> -P<port>"
echo ""
echo "Please remember to change the above password as soon as possible!"
echo "MySQL user 'root' has no password but only allows local connections"
echo "========================================================================"
