# Kiến thức cơ bản DevOps
- Devops : là người đưa ra giải pháp giúp tôi ưu quy trình làm việc , tăng chất lượng làm việc và sản phẩm

- Linux : là 1 hệ điều hành : Tối ưu chi phí , bảo mật và ổn định , khả năng kiểm soát và linh hoạt , 
dễ phát triển và cập nhật , tương thích đa nền tảng , cộng đồng phát triển lớn

``` bash
# Lệnh reset IP
ssh-keygen -R 192.168.1.110
```

# Setup IP tĩnh cho môi trường On-pre

``` bash
sudo -i
nano /etc/netplan/ + tab

# Nội dung bên trong
dhcp4: false
addresses: [192.168.1.110/24]
gateway4: 192.168.1.1
nameservers:
  addresses: [8.8.8.8,8.8.4.4]

# Apply cấu hình
netplan apply
```

# Cách lệnh Linux cơ bản

``` bash
pwd # xem đang ở thư mục nào
whoami # xem đang là user nào
cd # để chuyển qua thư mục khác
ls # để xem tất cả các thư mục 
ls -lta # hiển thị tất cả các thư mục file sắp xếp mới đến cũ
ls -l # hiển thị nội dung dưới dạng danh sách 
mkdir # tạo một folder || mkdir -p để cấp thêm quyền tạo folder trong folder
touch # tạo một thư mục 
rm # xoá thư mục hoặc folder || sử dụng lệnh rm -r để cấp quyền xoá || sử dụng lệnh rm -rf 
cp -r folder/ /vitricanchuyentoi/ 
cp file/ /vitri/ 
adduser devops // tạo một user mới
mv /filehoacfoldercanchuyen/ denvitricanchuyen
tail -n folder hoặc file dự án
sudo usermod -aG group_name user_name # them user vao group
sudo deluser alice sudo # xoa user ra khoi group
sudo groupadd developers # tao 1 group moi
scp -r /thư mục cần di chuyển user@<ip-server>:/home/user # di chuyển 1 file vào bên trong server
```

# Triển khai dự án backend Springboot và frontend react dạng service

### Luôn giữ 1 tư duy rằng backend thì triển khai database và làm sao run dự án 

``` bash
### cài đặt theo dõi các tiến trình
apt install net-tools -y
netstat -tlpun
```

## 1. setup cho backend

### 1. setup thư mục, user và môi trường

``` bash
sudo -i
cd /home/user
mkdir project
cd project
git clone https://github.com/duyduc1/ticket-car.git

### setup user cho dự án
adduser backend
chown -R backend. /home/user/project/ticker-car
chmod -R 755 /home/user/project/ticker-car

### setup môi trường cho dự án
apt install openjdk-21-jdk openjdk-21-jre
apt install maven
```

### 2. setup database

``` bash
### cài đặt database
apt install mysql-server

### cấu hình database
systemctl stop mysql
nano /etc/mysql/mysql.conf.d/mysqld.cnf
# set up 127.0.0.1 thành 0.0.0.0
systemctl restart mysql
mysql -u root
```

- Cấu hình 1 user riêng cho database

``` sql
create database database-project;
create user 'user'@'%' identified by 'password';
grant all privileges on database-project.* to 'user'@'%';
flush privileges;
show databases;
```

- Thay đổi config bên source backend

``` bash
nano src/main/resources/application.properties

# setup ip database từ local thành IP Server
# Username và password thay đổi thành username và password vừa tạo trong database
```

### 3. Tiến hành build dự án

``` bash
mvn clean install -DskipTests=true
ls target/
java -jar target/SpringSecurity.JWT-0.0.1-SNAPSHOT.jar
mkdir -p /var/log/backend
```

### 4. tiến hành setup service backend

``` bash
nano /etc/systemd/system/backend.service

### nội dung bên trong file backend.service
[Service]
Type=simple
User=backend
Restart=Always
WorkingDirectory=/home/user/project/ticker-car
ExecStart= java -jar target/SpringSecurity.JWT-0.0.1-SNAPSHOT.jar
StandardOutput=append:/var/log/backend/backend.log     
StandardError=append:/var/log/backend/backend.err

### Chạy file service
systemctl daemon-reload
systemctl start backend.service
systemctl status backend.service
```
 

## 2. setup cho frontend

### 1. setup thư mục, user và môi trường

``` bash
### setup thư mục dự án
sudo -i
cd /home/user
mkdir project
cd project
git clone https://github.com/duyduc1/frontend.git

### setup user cho dự án
adduser frontend
chown -R frontend. /home/user/project/frontend
chmod -R 755 /home/user/project/frontend

### setup môi trường cho dự án
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
apt-get install nodejs -y
sudo npm install -g npm@latest
```

### 2. tiến hành setup service frontend

``` bash
nano /etc/systemd/system/frontend.service

### nội dung bên trong file backend.service
[Service]
Type=simple
User=frontend
Restart=Always
WorkingDirectory=/home/user/project/frontend
ExecStart= npm run start -- --port=3000

### Chạy file service
systemctl daemon-reload
systemctl start frontend.service
systemctl status frontend.service
```

# Setup Nginx gắn domain

1. build dự án frontend React

``` bash
cd /home/user/project/frontend
npm run build
mv build /var/www/html
```

2. cài đặt nginx và setup domain

``` bash
sudo apt install nginx -y
nano /etc/nginx/conf.d/name-domain.vn.conf

server {
    listen 80;
    server_name name-domain.vn;

    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl http2;
    server_name name-domain.vn;

    root /var/www/html/build;
    index index.html;

    # Đường dẫn tới file cert
    ssl_certificate /etc/ssl/certs/name-domain.vn.crt;       # hoặc fullchain.pem
    ssl_certificate_key /etc/ssl/private/name-domain.vn.key; # hoặc privkey.pem

    location / {
        try_files $uri /index.html;
    }

    location /api/ {
        proxy_pass http://<IP-SERVER>:8080/api/; # port BE
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}

# kiểm tra syntax
sudo nginx -t

# Reload nginx
sudo systemctl restart nginx
```

- hoặc

``` bash
server {
    listen 80;
    server_name duc-domain.vn www.duc-domain.vn;

    root /var/www/html/build;
    index index.html;

    location / {
        try_files $uri /index.html;
    }

    # location /api/ {
    #     proxy_pass http://127.0.0.1:8080/api/;
    #     proxy_http_version 1.1;
    #     proxy_set_header Host $host;
    #     proxy_set_header X-Real-IP $remote_addr;
    #     proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    #     proxy_set_header X-Forwarded-Proto $scheme;
    # }
}

```

# Cài đặt gitlab và shell host

``` bash
curl -s https://packages.gitlab.com/install/repositories/gitlab/gitlab-ee/script.deb.sh | sudo bash
sudo apt-get install gitlab-ee=18.0.2-ee.0
nano /etc/gitlab/gitlab.rb

# update lại thành domain
external_url 'https://gitlab-ctl.greenglobal.com.vn'
# Tắt HTTPS nội bộ (vì SSL nằm ở proxy ngoài)
nginx['listen_https'] = false
nginx['listen_port'] = 80
		
# Bắt buộc GitLab tin tưởng proxy
nginx['proxy_set_headers'] = {
  "X-Forwarded-Proto" => "https",
  "X-Forwarded-Ssl" => "on"
}

# reload gitlab
sudo gitlab-ctl reconfigure

# xem password
cat /etc/gitlab/initial_root_password

# Truy cập domain của git
# username là root , password lấy trong initial_root_password 
```

- Nếu là domain tự host hãy dùng lệnh sau

- Nhớ add <ip-server> <tên-domain-git> ví dụ 10.1.0.13 git.vuduyduc.vn
# Đẩy dự án lên git

1. Tạo một repo trước trên gitlab vừa setup

``` bash
git config --global user.name "Duc"
git config --global user.email "vuduyduc550@gmail.com"
git clone http://git.duyduc.tech/foodweb1/foodweb.git
git checkout -b main
git add .
git commit -m "push(project-demo)"
git push --set-upstream origin main
```

# Setup gitlab-runner và triển khai CI/CD

1. triển khai gitlab-runner

``` bash
curl -L "https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh" | bash
apt-get install gitlab-runner
gitlab-runner register

# Enter the gitlab instance URL ( - bỏ link của gitlab vào trong này)
# Enter the registration Token ( - Vào CI/CD -> gitlab-runner -> lấy token vào dán vào)
# Enter the description for the runner ( - có thể bỏ tên của server vào ví dụ mô tả là deploy )
# Enter the tags for the runner ( - có thể bỏ tên của server vào ví dụ tags là deploy )
# Enter option maintenance note for the runner ( - gõ shell ) 
nano /etc/gitlab-runner/config.toml 
nohup gitlab-runner run --working-directory /home/gitlab-runner --config/etc/gitlab-runner/config.toml --service gitlab-runner --user gitlab-runner 2>&1 &
ps -ef| grep gitlab-runner
```

2. Cấp quyền cho gitlab-runner không sử dụng password

``` bash
visudo
gitlab-runner ALL=(ALL) NOPASSWD: ALL
gitlab-runner ALL=(ALL) NOPASSWD: /bin/mkdir*
gitlab-runner ALL=(ALL) NOPASSWD: /bin/mv*
gitlab-runner ALL=(ALL) NOPASSWD: /bin/cp*
gitlab-runner ALL=(ALL) NOPASSWD: /bin/chown*
gitlab-runner ALL=(ALL) NOPASSWD: /bin/rm*
gitlab-runner ALL=(ALL) NOPASSWD: /sbin/runuser
gitlab-runner ALL=(ALL) NOPASSWD: /usr/sbin/nginx*
gitlab-runner ALL=(ALL) NOPASSWD: /bin/su backend*
```

3. Setup key env cho project nếu không muốn public keyy trong repo

- Vào dự án Gitlab 

- Truy cập: Settings → CI/CD → Variables

- Bấm "Add variable"

- Nhập: 

> Key: ENV_CONTENT

> Value:

``` env
DB_HOST=192.168.230.140
DB_PORT=5432
DB_USERNAME=postgres
DB_PASSWORD=postgres
DB_DATABASE=mydb
```

4. Tạo file (.gitlab-ci.yml)

## Springboot

``` yml
stages:
  - build
  - deploy
  - showlog

variables:
  DEPLOY_DIR: /opt/backend-data
  DATA_LOG: /var/log/java
  JAR_NAME: <file-build-sau-khi-build-trong-du-an-springboot>.jar
  JAR_PATH: target/<file-build-sau-khi-build-trong-du-an-springboot>.jar
  PORT: 8080

build:
  stage: build
  variables:
    GIT_STRATEGY: clone
  script:
    - mvn clean install
  tags:
    - deploy

deploy:
  stage: deploy
  variables:
    GIT_STRATEGY: none
  script:
    - sudo mkdir -p $DATA_LOG
    - sudo chown -R gitlab-runner:gitlab-runner $DATA_LOG
    - sudo fuser -k $PORT/tcp || true
    - sudo mkdir -p $DEPLOY_DIR
    - sudo cp $JAR_PATH $DEPLOY_DIR
    - sudo chown -R gitlab-runner:gitlab-runner $DEPLOY_DIR
    - cd $DEPLOY_DIR
    - nohup java -jar $JAR_NAME > $DATA_LOG/backend.log 2>&1 &
  tags:
    - deploy

showlog:
  stage: showlog
  variables:
    GIT_STRATEGY: none
  script:
    - echo "Showing latest log lines..."
    - cat $DATA_LOG/backend.log
  tags:
    - deploy
```

## React

``` yml
stages:
  - build
  - deploy
  - showlog

build:
  stage: build
  variables:
    GIT_STRATEGY: clone
  script:
    - npm install
    - npm run build || true
  artifacts:
    paths:
      - build/
  tags:
    - deploy

deploy:
  stage: deploy
  variables:
    GIT_STRATEGY: none
  script:
    - sudo rm -rf /var/www/html/*
    - sudo mv build/ /var/www/html/
    - sudo chown -R gitlab-runner:gitlab-runner /var/www/html/build/
    - sudo nginx -t
    - sudo nginx -s reload
  tags:
    - deploy

showlog:
  stage: showlog
  variables:
    GIT_STRATEGY: none
  script:
    - echo "Nginx Access Log:"
    - sudo tail -n 100 /var/log/nginx/access.log || true
    - echo "Nginx Error Log:"
    - sudo tail -n 100 /var/log/nginx/error.log || true
  tags:
    - deploy
```

## Nest

``` yml
stages:
  - build
  - deploy
  - showlog

variables:
  DEPLOY_DIR: /opt/backend-data
  APP_NAME: main.js
  DIST_DIR: dist
  PORT: 3000

build:
  stage: build
  variables:
    GIT_STRATEGY: clone
  script:
    - npm install
    - npm run build 
  tags:
    - deploy

deploy:
  stage: deploy
  variables:
    GIT_STRATEGY: none
  script:
    - sudo fuser -k $PORT/tcp || true
    - sudo mkdir -p $DEPLOY_DIR
    - sudo cp -r $DIST_DIR/* $DEPLOY_DIR/
    - sudo cp package*.json $DEPLOY_DIR/
    # Tạo file .env từ GitLab CI variable
    - echo "$ENV_CONTENT" > .env
    - sudo cp .env $DEPLOY_DIR/  
    - sudo chown -R gitlab-runner:gitlab-runner $DEPLOY_DIR
    - cd $DEPLOY_DIR
    - export $(cat .env | xargs)
    - npm install --omit=dev
    - nohup node $APP_NAME > nohup.out 2>&1 &
  tags:
    - deploy

showlog:
  stage: showlog
  variables:
    GIT_STRATEGY: none
  script:
    - tail -n 100 $DEPLOY_DIR/nohup.out
  tags:
    - deploy
```

## Next

``` yml
stages:
  - build
  - deploy
  - showlog

variables:
  DEPLOY_DIR: /opt/frontend-data
  PORT: 4000

build:
  stage: build
  variables:
    GIT_STRATEGY: clone
  script:
    - npm install
    - npm run build      
  artifacts:
    paths:
      - .next
      - public
      - package*.json
  tags:
    - deploy

deploy:
  stage: deploy
  variables:
    GIT_STRATEGY: none
  script:
    - sudo fuser -k $PORT/tcp || true
    - sudo mkdir -p $DEPLOY_DIR
    - sudo cp -r .next public package*.json $DEPLOY_DIR/
    # Copy file .env từ biến CI
    - echo "$ENV_CONTENT" > .env
    - sudo cp .env $DEPLOY_DIR/
    - sudo chown -R gitlab-runner:gitlab-runner $DEPLOY_DIR
    - cd $DEPLOY_DIR
    - export $(cat .env | xargs)
    - npm install --omit=dev
    - PORT=$PORT nohup npm run start > nohup.out 2>&1 &
  tags:
    - deploy

showlog:
  stage: showlog
  variables:
    GIT_STRATEGY: none
  script:
    - sleep 20
    - tail -n 1000 $DEPLOY_DIR/nohup.out
  tags:
    - deploy
```

# Cài đặt và sử dụng Docker

1. Setup thư mục

``` bash
mkdir tools
cd tools
mkdir docker
cd docker/
nano install-docker.sh
```

2. Cài đặt bằng shellscript

``` bash
#!/bin/bash
sudo apt update
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y docker-ce
sudo systemctl start docker
sudo systemctl enable docker
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker --version
docker-compose --version
```

3. Run file script

``` bash
chmod +x install-docker.sh
bash install-docker.sh
``` 

4. Thao tác với docker

``` bash 
# Kiểm tra phiên bản Docker
docker --version

# Kiểm tra trạng thái Docker
docker info

# Danh sách tất cả các lệnh Docker
docker --help

## Làm việc với Docker Images
# Liệt kê các Docker Images
docker images

# Tải một image từ Docker Hub
docker pull <image-name>:<tag>

# Xóa một image
docker rmi <image-id>

# Xây dựng image từ Dockerfile
docker build -t <image-name>:<tag> .

# Gắn thẻ (tag) cho một image
docker tag <image-id> <new-image-name>:<new-tag>

# Đẩy image lên Docker Hub
docker push <image-name>:<tag>

## Làm việc với Containers
# Liệt kê các container đang chạy
docker ps

# Liệt kê tất cả container (bao gồm cả container đã dừng)
docker ps -a

# Chạy một container
docker run --name=<container-name> -dp <port-container>:<port-application> <image-name>:<tag>

# Dừng một container
docker stop <container-id>

# Khởi động lại container
docker restart <container-id>

# Xóa một container
docker rm <container-id>

# Truy cập vào một container đang chạy
docker exec -it <container-id> /bin/bash

## Lệnh về Mạng (Network)
# Liệt kê các mạng (network)
docker network ls

# Tạo một mạng mới
docker network create <network-name>

# Kết nối một container vào mạng
docker network connect <network-name> <container-id>

# Ngắt kết nối một container khỏi mạng
docker network disconnect <network-name> <container-id>

## Xem Logs và Debug
# Xem logs của container
docker logs <container-id>

# Theo dõi logs theo thời gian thực
docker logs -f <container-id>

# Xem chi tiết thông tin của container
docker inspect <container-id>

# Kiểm tra hiệu suất container
docker stats

## Dọn dẹp hệ thống
# Xóa các container đã dừng
docker container prune

# Xóa các image không sử dụng
docker image prune

# Xóa toàn bộ tài nguyên không sử dụng (container, image, network, volume)
docker system prune -a

## Các lệnh thường dùng hàng ngày
# Kiểm tra container đang chạy
docker ps

# Kiểm tra các image có sẵn
docker images

# Chạy một container
docker run -d --name <container> <image>

# Dừng một container
docker stop <container>

# Xóa một container
docker rm <container>

# Tải một image
docker pull <image>

# Xây dựng một image
docker build -t <image-name>:<tag> .

# Xem logs của container
docker logs <container>

# Truy cập vào container
docker exec -it <container> /bin/bash

# Khởi động docker-compose
docker-compose up -d || docker-compose -f file.yml up -d 

# tắt bằng docker compose
docker-compose down || docker-compose -f file.yml down
```

# Dockerfile cho dự án

### Dockerfile Springboot

``` Dockerfile
# Build stage
FROM maven:3.9.6-eclipse-temurin-21 AS build

WORKDIR /app
COPY . .
RUN mvn clean package -DskipTests

# Runtime stage
FROM eclipse-temurin:21-jdk

WORKDIR /run
COPY --from=build /app/target/ecom-proj-0.0.1-SNAPSHOT.jar /run/ecom-proj-0.0.1-SNAPSHOT.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "/run/ecom-proj-0.0.1-SNAPSHOT.jar"]
```

### Dockerfile React

``` Dockerfile
FROM node:18.18-alpine as build

WORKDIR /app
COPY . .

RUN npm install --force
RUN npm run build

FROM nginx:alpine

COPY --from-build /app/dist /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

### docker-compose

``` yml
version: '3.8'
services:
  backend:
    build:
      context: .
      dockerfile: Dockerfile
    ports:
      - "8080:8080"
    depends_on:
      - mysql
    environment:
      SPRING_DATASOURCE_URL: jdbc:mysql://mysql:3306/vegetfood
      SPRING_DATASOURCE_USERNAME: vegetfood
      SPRING_DATASOURCE_PASSWORD: vegetfood
    container_name: vegetfood-backend
    restart: always

  mysql:
    image: mysql:8.0
    volumes:
      - /db/mysql-1:/var/lib/mysql
    environment:
      MYSQL_ROOT_PASSWORD: vegetfood
      MYSQL_DATABASE: vegetfood
      MYSQL_USER: vegetfood
      MYSQL_PASSWORD: vegetfood
    ports:
      - "3307:3306"
    container_name: mysql-1
    restart: always
```

# Push Image lên registry (DockerHub)

``` bash
cd
docker login
# Nhập username Dockerhub
# Nhập Password Dockerhub

docker images
docker tag <id-image> vuduyduc/frontend:v1
docker push vuduyduc/frontend:v1
```

# Docker ci/cd

1. Chuyển gitlab-runner vào môi trường docker

``` bash
usermod -aG docker gitlab-runner
su gitlab-runner
docker login
```

2. Tiến hành setting env

- Vào setting -> CI/CD -> variables

- Điền vào thông tin

* REGISTRY_URL (điền ở phần key) : docker.io (điền ở phần value) // nhớ bỏ đi tích chọn protect variables

* REGISTRY_PROJECT (điền ở phần key) : vuduyduc764 (điền ở phần value) // nhớ bỏ đi tích chọn protect variables

* REGISTRY_USER (điền ở phần key) : vuduyduc764 (điền ở phần value) // nhớ bỏ đi tích chọn protect variables
	  
* REGISTRY_PASSWORD (điền ở phần key) : Vuduyduc28042002@ (điền ở phần value) // nhớ bỏ đi tích chọn protect variables 

3. Setup file .gitlab-ci.yml

### Dựng Docker CI/CD Dockerfile push lên dockerhub

``` yaml
variables:
   DOCKER_IMAGE: ${REGISTRY_URL}/${REGISTRY_PROJECT}/${CI_PROJECT_NAME}:${CI_COMMIT_TAG}_${CI_COMMIT_SHORT_SHA}
   DOCKER_CONTAINER: ${CI_PROJECT_NAME}
stages:
    - buildandpush
    - deploy
    - showlog

build:
    stage: buildandpush
    before_script:
        - echo "$REGISTRY_PASSWORD" | docker login -u "$REGISTRY_USER" --password-stdin
    variables:
        GIT_STRATEGY: clone
    script:
        - docker build -t $DOCKER_IMAGE .
        - docker push $DOCKER_IMAGE
    tags:
        - deploy
deploy:
    stage: deploy
    before_script:
        - echo "$REGISTRY_PASSWORD" | docker login -u "$REGISTRY_USER" --password-stdin
    variables:
        GIT_STRATEGY: none
    script:
        - docker pull $DOCKER_IMAGE
        - docker rm -f $DOCKER_CONTAINER
        - docker run --name $DOCKER_CONTAINER -dp 8888:8081 $DOCKER_IMAGE
        - docker image prune -af
    tags:
        - deploy

showlog:
    stage: showlog
    variables:
        GIT_STRATEGY: none
    script:
        - sleep 20
        - docker logs $DOCKER_CONTAINER
    tags:
        - deploy
```

### Dựng Docker CI/CD Dockerfile không push lên dockerhub

``` yml
variables:
  DOCKER_IMAGE: ${CI_PROJECT_NAME}:${CI_COMMIT_TAG}_${CI_COMMIT_SHORT_SHA}
  DOCKER_CONTAINER: ${CI_PROJECT_NAME}

stages:
  - build
  - deploy
  - showlog

build:
  stage: build
  variables:
    GIT_STRATEGY: clone
  script:
    - docker build -t $DOCKER_IMAGE .
  tags:
    - deploy

deploy:
  stage: deploy
  variables:
    GIT_STRATEGY: none
  script:
    - docker rm -f $DOCKER_CONTAINER || true
    - echo "Running new container..."
    - docker run -d --name $DOCKER_CONTAINER -p 8080:8080 $DOCKER_IMAGE
    - docker image prune -af
  tags:
    - deploy

showlog:
  stage: showlog
  variables:
    GIT_STRATEGY: none
  script:
    - sleep 10
    - docker logs --tail=50 $DOCKER_CONTAINER
  tags:
    - deploy

```

### Docker CI/CD docker-compose

* Nhớ thêm image: ${REGISTRY_URL}/${REGISTRY_PROJECT}/backend:${CI_COMMIT_TAG}_${CI_COMMIT_SHORT_SHA} trong file docker-compose <br> sau bước build nếu muốn push lên dockerhub registry

``` yml
variables:
  DOCKER_COMPOSE_FILE: fullstack-compose.yml
  GIT_STRATEGY: clone

stages:
  - build
  - deploy
  - showlog

build:
  stage: build
  before_script:
    - echo "$REGISTRY_PASSWORD" | docker login -u "$REGISTRY_USER" --password-stdin $REGISTRY_URL
  script:
    # Build & push toàn bộ image được định nghĩa trong docker-compose.yml
    - docker compose -f $DOCKER_COMPOSE_FILE build
    - docker compose -f $DOCKER_COMPOSE_FILE push
  tags:
    - deploy

deploy:
  stage: deploy
  variables:
    GIT_STRATEGY: none
  script:
    - echo "Pull latest images from registry..."
    - docker compose -f $DOCKER_COMPOSE_FILE pull
    - echo "Restarting services..."
    - docker compose -f $DOCKER_COMPOSE_FILE down
    - docker compose -f $DOCKER_COMPOSE_FILE up -d
    - docker image prune -af
  tags:
    - deploy

showlog:
  stage: showlog
  variables:
    GIT_STRATEGY: none
  script:
    - sleep 10
    - docker compose -f fullstack-compose.yml logs backend --tail=50
  tags:
    - deploy
```

### Nếu không muốn push docker image lên docker hub

``` yml
variables:
  DOCKER_COMPOSE_FILE: fullstack-compose.yml
  GIT_STRATEGY: clone

stages:
  - build
  - deploy
  - showlog

build:
  stage: build
  script:
    - echo "Building local Docker images..."
    - docker compose -f $DOCKER_COMPOSE_FILE build
  tags:
    - deploy

deploy:
  stage: deploy
  variables:
    GIT_STRATEGY: none
  script:
    - echo "Deploying local Docker images..."
    - docker compose -f $DOCKER_COMPOSE_FILE down
    - docker compose -f $DOCKER_COMPOSE_FILE up -d
    - docker image prune -af
  tags:
    - deploy

showlog:
  stage: showlog
  variables:
    GIT_STRATEGY: none
  script:
    - sleep 10
    - docker compose -f fullstack-compose.yml logs backend --tail=50
  tags:
    - deploy

```

# Thiết lập cài đặt Jenkins

- Setup thư mục 

``` bash
mkdir tools
cd tools/
mkdir jenkins
cd jenkins/
nano jenkins-install.sh
```

- File tự động

``` bash
apt install openjdk-17-jdk -y
java --version
curl -fsSL https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -
sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 5BA31D57EF5975CA
apt-get update
apt install jenkins -y
systemctl start jenkins
systemctl enable jenkins
ufw allow 8080
```

- Chạy file

``` bash
chmod +x jenkins-install.sh
bash jenkins-install.sh
systemctl status jenkins

# Lấy mật khẩu
cat /var/lib/jenkins/secrets/initialAdminPassword
```

### shel host cho Jenkins

``` bash
sudo apt install nginx
nano /etc/nginx/conf.d/jenkins.duyduc.tech.conf

# nội dung bên trong nginx
server {
    listen 80;
    server_name jenkins.duyduc.tech;

    location / {
        proxy_pass http://127.0.0.1:8080;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection keep_alive;
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}

# reload nginx
nginx -t 
nginx -s reload
```

- Nhớ tạo 1 User ADMIN để truy cập vào Jenkins

# Setup CI/CD Jenkins


### Trên server cần triển khai (lab-server)

``` bash
apt install openjdk-17-jdk openjdk-17-jre -y

# Nếu là dự án NodeJS thì cài đặt
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
apt-get install nodejs -y
sudo npm install -g npm@latest

# Thêm user Jenkins vào trong server
adduser jenkins
```

### Trên giao diện Jenkins ( Tạo agent )

1. vào dashboard -> manage jenkins -> nodes -> new node (đặt tên : lab-server , tích chọn Permanent Agent) -> create

2. Trong Name -> lables ( tương ứng với tên server ví dụ lab-server ) -> Remote root directory (tạo thư mục /var/lib/jenkins và <br> nhớ tạo /var/lib/jenkins trong cả lab-server)-> trước khi save nhìn bước ở dưới -> save

3. mở tab google thứ 2 vào link của jenkins -> dashboard -> manage jenkins -> security -> Agents (TCP port for inbound agent) chọn <br> fixed để port 8999 (port này trên) jenkins-server và không có dịch vụ nào chạy -> save -> sau đó hãy save bước ở trên 

4. netstat -tlpun ( trong jenkins-server sẽ thấy cổng 8999 )

5. Nhấn vào lab-server sau khi được tạo sẽ xuất hiện hướng dẫn Recommend sử dụng Unix nhớ copy lại

### Bên trong lab-server

``` bash
chown jenkins. /var/lib/jenkins 
cd /var/lib/jenkins
su jenkins

# Lấy từ bên trong Jenkins sau khi setup và paste vào trong này
echo 2885cab07ec8e099947e97435d5625d2da2ea7934efc40fcf71588f83ab6ebc6 > secret-file
curl -sO http://jenkins.duyduc.tech:8080/jnlpJars/agent.jar
java -jar agent.jar -url http://jenkins.duyduc.tech:8080/ -secret @secret-file -name "lab-server" -webSocket -workDir "/var/lib/jenkins" > nohup.out 2>&1 &
```

* quay lại trang jenkins rồi F5 lại sẽ thấy Agent is connected.

### Trên giao diện Jenkins

1. Dashboard -> new Item -> Folder (đặt tên tùy theo dự án Action in lab) -> save 

2. Dashboard -> manage jenkins -> plugins -> tích chọn vào gitlab && blue ocean -> <br> install -> tích chọn vào Restart Jenkins when installation is complete

3. Sau khi install thành công -> installed plugin sẽ thấy blue ocean && gitlab-plugins

4. Dashboard -> manage jenkins -> system -> kéo xuống sẽ thấy Gitlab

* Collection name : gitlab server

* Gitlab host URL : http://gitlab.duyduc.tech (ví dụ)

* Credential (ở đây cần kết nối qua API Token)  

### Qua Gitlab tạo một user jenkins có quyền admin

* Đăng nhập bằng tài khoản jenkins -> edit profile -> access Token -> Token name (đặt tên token : token for jenkins server connection hoặc tùy theo ý tưởng của bạn)

* Select scopes -> tích chọn api -> create personal access token

* nhớ lưu lại Api token sau khi tạo

### qua lại bên Jenkins

* Credentials: Add -> jenkins -> Add credentials <br> -> kind (Gitlab API token) 
<br> -> API token (paste API Token vừa lấy ở gitlab vào đây) <br> -> ID : Jenkins-gitlab-user <br> -> description : Jenkins-gitlab-user -> Add 

* Sau khi tạo thành công sẽ thấy ở phần Credentials -> chọn Gitlab API token(jenkins-gitlab-user) - Test Connection -> save

### Hướng dẫn kết nối gitlab của dự án đến jenkins

* Dashboard -> Action in lab -> new Item -> pipeline(tên dự án ví dụ shoeshop) -> Ok -> Discard old build -> Max of builds to keep (10) <br> -> kéo xuống build triggers -> build when a change is pushed to gitlab -> chọn Push Event && Accepted Merge Request Events <br> -> kéo xuống Pipeline -> Definition ( chọn pipeline script from SCM ) -> SCM ( chọn git ) -> Repository URL ( dùng link git của dự án => http://gitlab.duyduc.tech/vegetfood/vegetfood.git ) <br> -> kéo xuống Credentials -> Add -> jenkins -> Add Credentials -> Kind (Username with password) -> Username : jenkins (được tạo trên gitlab) && Password : paste API Token vừa lấy ở gitlab vào đây <br> -> ID : jenkins-gitlab-user-account -> Description : jenkins-gitlab-user-account -> Add <br> -> Và sau đó out ra Credentials -> chọn user vừa được tạo (jenkins-gitlab-user-account) <br> -> kéo xuống Branches to build -> Branch Specifier (chọn nhánh muốn build khi có merge request ví dụ develop , ngoài ra có thể Add Branch các nhánh khác vào) -> save

### Vào Gitlab của dự án 

* Menu -> Admin -> Setting -> Network -> Outbound requests -> click chọn cả 2 tuỳ chọn (Allow Requests to the local network from the web hooks and services <br>, Allow Requests to the local network from system hooks)  -> Save changes

* Settings -> Webhooks -> ở phần URL (format chính của URL http://<URL của jenkins>/project/<Đường dẫn dự án trên jenkins>/ <br> ví dụ:
http://103.228.75.154:8080/project/Action_in_lab/vegetfood) <br> -> tích chọn Push Event && Tags event && merge request events && bỏ tuỳ chọn enable ssl -> Add webhook

### Trên dashboard Jenkins

* Cấu hình Jenkins để cho phép anonymous được trigger job

1. Truy cập Jenkins với tài khoản admin -> Vào Manage Jenkins → Security.

2. Trong mục Authorization, chọn:

* ✅ "Matrix-based security".

* Tìm hàng "anonymous" → bật quyền:
		
* Job > Build (và Job > Read, nếu cần)

* Lưu lại.

### Vào Gitlab của dự án 

* Kiểm tra lại GitLab webhook.
	  
* Sau khi Add webhook -> ở dưới sẽ xuất hiện Project Hooks(1) -> Chọn Test -> tích chọn Push events 

### Bên trong lab-server

``` bash
visudo

### nội dung 
jenkins  ALL=(ALL) NOPASSWD: ALL
jenkins  ALL=(ALL) NOPASSWD: /bin/mkdir*
jenkins  ALL=(ALL) NOPASSWD: /bin/cp*
jenkins  ALL=(ALL) NOPASSWD: /bin/chown*
jenkins  ALL=(ALL) NOPASSWD: /bin/su springbe
```

### Vào Gitlab của dự án

1. Tạo một Jenkinsfile bên nhánh develop của gitlab và triển khai pipeline trên Repo nhánh develop của dự án đó 

2. Truy cập Jenkins web: http://your-jenkins-url
			
3. Chọn Manage Jenkins → Credentials

4. Chọn phạm vi Global -> Click (global) → Add Credentials

5. Ở màn hình “Add Credentials”, chọn:
			
- Kind: Secret file

- File: chọn file postgres.env bạn đã chuẩn bị

- ID: đặt một ID dễ nhớ, ví dụ: postgres-env-file

- Description: PostgreSQL Environment File (tuỳ chọn)

- Nhấn OK để lưu

### Jenkinsfile cho Springboot

``` bash
pipeline {
    agent { label 'lab-server' }

    environment {
        DEPLOY_DIR = "/opt/backend-data"
        JAR_NAME   = "SpringSecurity.JWT-0.0.1-SNAPSHOT.jar"
        JAR_PATH   = "target/${JAR_NAME}"
        PORT       = "8080"
    }

    stages {
        stage('Build') {
            steps {
                script {
                    sh 'mvn clean install'
                }
            }
        }

        stage('Deploy') {
            steps {
                # Nếu có ENV
                withCredentials([file(credentialsId: 'mysql-env-file', variable: 'ENV_FILE')]) {
                    sh '''
                        sudo fuser -k ${PORT}/tcp || true
                        sudo mkdir -p ${DEPLOY_DIR}
                        sudo cp ${JAR_PATH} ${DEPLOY_DIR}
                        sudo cp $ENV_FILE ${DEPLOY_DIR}/.env
                        sudo chown -R jenkins:jenkins ${DEPLOY_DIR}
                        cd ${DEPLOY_DIR}
                        export $(cat .env | xargs)
                        sudo -u jenkins nohup java -jar ${JAR_NAME} > nohup.out 2>&1 &
                    '''
                }

                # Nếu không có ENV
                script {
                    sh """
                        sudo fuser -k ${PORT}/tcp || true
                        sudo mkdir -p ${DEPLOY_DIR}
                        sudo cp ${JAR_PATH} ${DEPLOY_DIR}
                        sudo chown -R jenkins:jenkins ${DEPLOY_DIR}
                        cd ${DEPLOY_DIR}
                        sudo -u jenkins nohup java -jar ${JAR_NAME} > nohup.out 2>&1 &
                    """
                }
            }
        }

        stage('Show Log') {
            steps {
                script {
                    sh "tail -n 50 ${DEPLOY_DIR}/nohup.out || echo 'No log found.'"
                }
            }
        }
    }

    post {
        always {
            script {
                sh """
                    sudo chown -R jenkins:jenkins ${DEPLOY_DIR} || true
                    sudo chmod -R 755 ${DEPLOY_DIR} || true
                """
            }
        }
    }
}
```

### Jenkinsfile cho NestJS

``` bash
pipeline {
    agent { label 'lab-server' }

    environment {
        DEPLOY_DIR = "/opt/backend-data"
        APP_NAME   = "main.js"
        DIST_DIR   = "dist"
        PORT       = "3000"
    }

    stages {

        stage('Build') {
            environment {
                GIT_STRATEGY = "clone"
            }
            steps {
                sh '''
                    npm install
                    npm run build
                '''
            }
        }

        stage('Deploy') {
            environment {
                GIT_STRATEGY = "none"
            }
            steps {
                # Trường hợp env trong jenkins
                withCredentials([file(credentialsId: 'postgres-env-file', variable: 'ENV_FILE')]) {
                    sh '''
                        sudo fuser -k $PORT/tcp || true
                        sudo mkdir -p $DEPLOY_DIR
                        sudo cp -r $DIST_DIR/* $DEPLOY_DIR/
                        sudo cp package*.json $DEPLOY_DIR/
                        sudo cp $ENV_FILE $DEPLOY_DIR/.env
                        sudo chown -R jenkins:jenkins $DEPLOY_DIR
                        cd $DEPLOY_DIR
                        export $(cat .env | xargs)
                        npm install --omit=dev
                        sudo -u jenkins nohup node $APP_NAME > nohup.out 2>&1 &
                    '''
                }

                # Trường hợp không cần env 
                script {
                    sh """
                        sudo fuser -k $PORT/tcp || true
                        sudo mkdir -p $DEPLOY_DIR
                        sudo cp -r $DIST_DIR/* $DEPLOY_DIR/
                        sudo cp package*.json $DEPLOY_DIR/
                        sudo chown -R jenkins:jenkins $DEPLOY_DIR
                        cd $DEPLOY_DIR
                        npm install --omit=dev
                        sudo -u jenkins nohup node $APP_NAME > nohup.out 2>&1 &
                    """
                }
            }
        }

        stage('Show Log') {
            environment {
                GIT_STRATEGY = "none"
            }
            steps {
                sh '''
                    tail -n 100 $DEPLOY_DIR/nohup.out || echo "❌ No log found."
                '''
            }
        }
    }

    post {
        always {
            script {
                sh """
                    sudo chown -R jenkins:jenkins $DEPLOY_DIR || true
                    sudo chmod -R 755 $DEPLOY_DIR || true
                """
            }
        }
    }
}

```

* Sau khi triển khai xong thì qua bên Jenkins của dự án sẽ xuất hiện dưới Build History , có thể vào Blue Ocean để xem logs của Pipelines

# Monitor with Grafana

### Cài đặt Node Exporter trên các máy chủ

- Node Exporter thu thập metric hệ thống (CPU, RAM, disk, v.v.) từ các máy chủ. Cài đặt trên cả 3 máy chủ (10.1.0.175, 10.1.0.172, 10.1.0.176).

1. Cài đặt docker (đã có sẵn cách setup cài đặt docker tự động hoá)

2. Chạy Node Exporter bằng Docker

- Trên mỗi máy chủ, tạo một container Node Exporter:

``` bash
docker run -d \
  --name node-exporter \
  -p 9100:9100 \
  --restart always \
  prom/node-exporter:latest
```

3. Cấu hình Prometheus và Grafana trên máy chủ chính (10.1.0.175)

- Prometheus và Grafana sẽ được triển khai bằng Docker Compose trên 10.1.0.175.

``` bash
mkdir -p ~/monitoring
cd ~/monitoring
nano prometheus.yaml

# Nội dụng trong prometheus.yml	
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['10.1.0.175:9090']  # Prometheus tự giám sát

  - job_name: 'node-exporter'
    static_configs:
      - targets:
          - '10.1.0.175:9100'  # Node Exporter trên máy chủ chính
          - '10.1.0.172:9100'  # Node Exporter trên máy chủ 2
          - '10.1.0.176:9100'  # Node Exporter trên máy chủ 3
```

``` yaml
services:
  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus_data:/prometheus
    ports:
      - "9090:9090"
    restart: always
    networks:
      - monitoring

  grafana:
    image: grafana/grafana:latest
    container_name: grafana
    volumes:
      - grafana_data:/var/lib/grafana
    ports:
      - "3000:3000"
    restart: always
    networks:
      - monitoring

volumes:
  prometheus_data:
  grafana_data:

networks:
  monitoring:
    driver: bridge
```

- chạy file yaml

``` bash
docker-compose up -d --buid
docker ps
```

- Truy cập:
		
- Prometheus: http://10.1.0.175:9090
		
- Grafana: http://10.1.0.175:3000 (Tài khoản mặc định: admin/admin, bạn sẽ được yêu cầu đổi mật khẩu).

4. Cấu hình Grafana
			
* Đăng nhập vào Grafana tại http://10.1.0.175:3000.

* Thêm nguồn dữ liệu (Data Source):

* Vào menu Connections > Data Sources > Add data source.

* Chọn Prometheus.

* Đặt URL: http://10.1.0.175:9090 (dùng tên service trong Docker Compose).

* Nhấn Save & Test.

* Tạo Dashboard:

* Vào Create > Import.

* Sử dụng ID dashboard phổ biến cho Node Exporter, ví dụ: 1860 (Node Exporter Full).

* Chọn nguồn dữ liệu Prometheus vừa thêm.

* Lưu dashboard để xem metric từ 3 máy chủ.

# Thiết lập registry

``` bash
wget https://github.com/goharbor/harbor/releases/download/v2.9.3/harbor-online-installer-v2.9.3.tgz
tar -xvzf harbor-online-installer-v2.9.3.tgz
cd harbor
cp harbor.yml.tmpl harbor.yml
nano harbor.yml
# hostname: 192.168.230.132 // sửa hostname thành IP hoặc domain 
# https related config
# https: // tắt https nếu không dùng domain và SSL
# https port for harbor, default is 443
# port: 443
# The path of cert and key files for nginx
# certificate: /your/certificate/path
# private_key: /your/private/key/path
harbor_admin_password: admin123 # đổi mật khẩu nếu cần

sudo nano /etc/docker/daemon.json
{
  "insecure-registries": ["192.168.230.132"]
}

./install.sh

docker login 192.168.230.132
docker images
# nhớ phải tạo project demo ở harbor_web trước khi push lên
docker tag registry:2 192.168.230.132/demo/myapp:latest 
docker push 192.168.230.132/demo/myapp:latest
```
