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
apt install openjdk-17-jdk openjdk-17-jre
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
# Enter the description for the runner ( - có thể bỏ tên của server vào ví dụ mô tả là devops-server )
# Enter the tags for the runner ( - có thể bỏ tên của server vào ví dụ tags là devops-server )
# Enter option maintenance note for the runner ( - gõ shell ) 
nano /etc/gitlab-runner/config.toml 
nohup gitlab-runner run --working-directory /home/gitlab-runner --config/etc/gitlab-runner/config.toml --service gitlab-runner --user gitlab-runner 2>&1 &
ps -ef| grep gitlab-runner
```