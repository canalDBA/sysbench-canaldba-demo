# SysBench Demo

## Prepare the environment

```bash
# Create the network
docker network create sysbench-demo

# Create the MySQL container
docker run --name=sysbench-demo-mysql --env MYSQL_ROOT_PASSWORD=rootpass \
   --mount type=bind,src=$(pwd)/mysql/config,dst=/etc/mysql/conf.d \
   --mount type=bind,src=$(pwd)/mysql/data,dst=/var/lib/mysql \
   --network sysbench-demo -d mysql/mysql-server:5.7

# Test MySQL connection as root
docker exec -it  sysbench-demo-mysql mysql -uroot -prootpass -e "SELECT USER()"


# Create MySQL user for sysbench
docker exec -it  sysbench-demo-mysql mysql -uroot -prootpass -e "CREATE DATABASE sbtest;CREATE USER sbtest@'%' IDENTIFIED BY 'password';GRANT ALL PRIVILEGES ON *.* to sbtest@'%';"

# Test MySQL connection
docker exec -it  sysbench-demo-mysql mysql -usbtest -ppassword -e "SELECT USER()"

# Lazy mode
alias sbdocker="docker run --rm=true --name=sysbench-container -v $(pwd)/sysbench/scripts:/opt --network=sysbench-demo severalnines/sysbench "
alias sbmysql="docker exec -it  sysbench-demo-mysql mysql -uroot -prootpass "

# First sysbench test
sbdocker sysbench cpu run

# Check the tests available
sbdocker ls /usr/share/sysbench/tests/

# Now the first against MySQL
sbdocker sysbench /usr/share/sysbench/tests/include/oltp_legacy/oltp.lua \
--db-driver=mysql \
--oltp-table-size=100000 \
--oltp-tables-count=4 \
--threads=4 \
--mysql-host=sysbench-demo-mysql \
--mysql-user=sbtest \
--mysql-password=password prepare

sbdocker sysbench /usr/share/sysbench/tests/include/oltp_legacy/oltp.lua \
--db-driver=mysql \
--oltp-table-size=100000 \
--oltp-tables-count=4 \
--threads=4 \
--mysql-host=sysbench-demo-mysql \
--mysql-user=sbtest \
--mysql-password=password run

sbdocker sysbench /usr/share/sysbench/tests/include/oltp_legacy/oltp.lua \
--db-driver=mysql \
--oltp-table-size=100000 \
--oltp-tables-count=4 \
--threads=4 \
--mysql-host=sysbench-demo-mysql \
--mysql-user=sbtest \
--mysql-password=password cleanup

# Another test
sbdocker sysbench /usr/share/sysbench/tests/include/oltp_legacy/insert.lua --db-driver=mysql \
--oltp-table-size=100000 \
--oltp-tables-count=4 \
--threads=4 \
--mysql-host=sysbench-demo-mysql \
--mysql-user=sbtest \
--mysql-password=password prepare

sbdocker sysbench /usr/share/sysbench/tests/include/oltp_legacy/insert.lua --db-driver=mysql \
--oltp-table-size=100000 \
--oltp-tables-count=4 \
--threads=4 \
--mysql-host=sysbench-demo-mysql \
--mysql-user=sbtest \
--mysql-password=password run

sbdocker sysbench /usr/share/sysbench/tests/include/oltp_legacy/insert.lua --db-driver=mysql \
--oltp-table-size=100000 \
--oltp-tables-count=4 \
--threads=4 \
--mysql-host=sysbench-demo-mysql \
--mysql-user=sbtest \
--mysql-password=password cleanup
```

## What about a custom script

```bash
ls /opt/create_tables.lua
```

```bash
sbdocker sysbench /opt/create_tables.lua \
--db-driver=mysql \
--threads=4 \
--mysql-host=sysbench-demo-mysql \
--mysql-user=sbtest \
--mysql-password=password prepare

sbdocker sysbench /opt/create_tables.lua \
--db-driver=mysql --threads=4 \
--mysql-host=sysbench-demo-mysql \
--mysql-user=sbtest \
--mysql-password=password run

sbdocker sysbench /opt/create_tables.lua \
--db-driver=mysql --threads=4 \
--mysql-host=sysbench-demo-mysql \
--mysql-user=sbtest \
--mysql-password=password cleanup
```

