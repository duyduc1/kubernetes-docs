# Nội dung

## Triển khai các loại databases bằng docker

### Triển khai docker

``` bash
touch docker-install.sh && chmod +x docker-install.sh && vi docker-install.sh
```

``` bash
#!/bin/bash
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update -y
sudo apt install docker-ce -y
sudo systemctl start docker
sudo systemctl enable docker
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker -v
docker-compose -v
```

``` bash
bash docker-install.sh
```

# 1. Cài đặt cloudbeaver bằng docker

``` bash
vi docker-compose-cloudbeaver.yml
```

``` yml
version: '3.8'
services:
  cloudbeaver:
    image: dbeaver/cloudbeaver:latest
    container_name: cloudbeaver
    ports:
      - "81:8978"
    volumes:
      - /data/cloudbeaver/:/opt/cloudbeaver/workspace
    restart: always
```

``` bash
docker-compose -f docker-compose-cloudbeaver.yml up -d
```

# 2. Cài đặt postgresql bằng docker

``` bash
vi docker-compose-postgresql.yml
```

``` yml
version: '3.8'
services:
  postgres:
    image: postgres:14
    container_name: postgres
    environment:
      POSTGRES_PASSWORD: "95a3FqXFsUDhxRd"
    ports:
      - "5432:5432"
    volumes:
      - /data/postgresql/:/var/lib/postgresql/data
    restart: always
```

``` bash
docker-compose -f docker-compose-postgresql.yml up -d
```

- username: postgres

# 3. Cài đặt mariadb bằng docker

``` bash
vi docker-compose-mariadb.yml
```

``` yml
version: '3.8'
services:
  mariadb:
    image: mariadb:10.6
    container_name: mariadb
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: "95a3FqXFsUDhxRd"
    ports:
      - "3306:3306"
    volumes:
      - /data/mysql/:/var/lib/mysql
```

``` bash
docker-compose -f docker-compose-mariadb.yml up -d
```

- username: root

# 4. Cài đặt sqlserver bằng docker

``` bash
vi docker-compose-mssql.yml
```

``` yml
version: '3.8'
services:
  mssql:
    image: mcr.microsoft.com/mssql/server:2019-latest
    container_name: mssql
    environment:
      SA_PASSWORD: "95a3FqXFsUDhxRd"
      ACCEPT_EULA: "Y"
    ports:
      - "1433:1433"
    volumes:
      - /data/mssql/:/var/opt/mssql
    restart: always
    user: "root"
```

``` bash
docker-compose -f docker-compose-mssql.yml up -d
```

- username: sa

# 5. Cài đặt mongodb bằng docker

``` bash
vi docker-compose-mongodb.yml
```

``` yml
version: '3.8'
services:
  mongodb:
    image: mongo:4.4
    container_name: mongodb
    ports:
      - "27017:27017"
    volumes:
      - /data/mongo:/data/db
    restart: always
```

``` bash
docker-compose -f docker-compose-mongodb.yml up -d
```

# 6. Cài đặt redis bằng docker

``` bash
vi docker-compose-redis.yml
```

``` yml
version: '3.8'
services:
  redis:
    image: redis:6.2
    container_name: redis
    ports:
      - "6379:6379"
    volumes:
      - /data/redis/:/data
    restart: always
```

``` bash
docker-compose -f docker-compose-redis.yml up -d
```

# 7. Cài đặt memcached bằng docker

``` bash
vi docker-compose-memcached.yml
```

``` bash
version: '3.8'
services:
  memcached:
    image: memcached:1.6
    container_name: memcached
    ports:
      - "11211:11211"
    volumes:
      - /data/memcached:/data
    restart: always
```

``` bash
docker-compose -f docker-compose-memcached.yml up -d
```

- Cài đặt memcached bằng docker

- Memcached là một hệ thống lưu trữ cache phân tán và trong bộ nhớ (in-memory caching <br> system), được sử dụng để tăng tốc độ truy xuất dữ liệu bằng cách lưu trữ dữ liệu <br> trong bộ nhớ RAM và được sử dụng cực kỳ rộng rãi trong các dự án thực tế từ các <br> công nghệ (ngôn ngữ lập trình) như Node.js, NetCore, Java, Php, Ruby, Python, Go,…

# 8. Cài đặt cassandra bằng docker

``` bash
vi docker-compose-cassandra.yml
```

``` bash
version: '3.8'
services:
  cassandra:
    image: cassandra:latest
    container_name: cassandra
    ports:
      - "9042:9042"
    volumes:
      - /data/cassandra:/var/lib/cassandra
    restart: always
```

``` bash
docker-compose -f docker-compose-cassandra.yml up -d
```

- Cài đặt cassandra bằng docker

- Cassandra là một hệ quản trị cơ sở dữ liệu NoSQL phân tán và được sử dụng trong các dự 
<br> án thực tế từ các công nghệ (ngôn ngữ lập trình) như Node.js, NetCore, Java, Php, <br> Ruby, Python, Go,…

# 9. Cài đặt oracle bằng docker

``` bash
vi docker-compose-oracle.yml
```

``` bash
version: '3.8'
services:
  oracle:
    image: oracleinanutshell/oracle-xe-11g
    container_name: oracle
    environment:
      - DB_SID=ORCLCDB
      - DB_PDB=ORCLPDB1
      - DB_DOMAIN=localdomain
      - ORACLE_PWD=95a3FqXFsUDhxRd
    ports:
      - "1521:1521"
    volumes:
      - /data/oracle:/opt/oracle/oradata
    shm_size: '1gb'
    restart: always
```

### Dùng 1 trong 2

``` bash
version: '3.8'

services:
  oracle:
    image: wnameless/oracle-xe-11g-r2:18.04-apex
    container_name: OracleDb
    restart: always
    environment:
      - ORACLE_ALLOW_REMOTE=true
      - ORACLE_DISABLE_ASYNCH_IO=true
      - ORACLE_ENABLE_XDB=true
    ports:
      - 5019:1521
      - 5020:8080

  dbeaver:
    image: dbeaver/cloudbeaver:22.1.1
    container_name: CloudBeaver
    restart: unless-stopped
    volumes:
      - dbeaver-data:/opt/cloudbeaver/workspace
    ports:
      - 5021:8978

volumes:
  dbeaver-data:
```

``` bash
docker-compose -f docker-compose-oracle.yml up -d
```

``` bash
# Oracle APEX

## http://localhost:5020/apex/apex_admin
## username: ADMIN
##  password: Oracle_11g

# Truy cập database

## Host name or IP server
## Port: 1521
## Db hoặc sid: xe
## DB credentials: system và oracle
```