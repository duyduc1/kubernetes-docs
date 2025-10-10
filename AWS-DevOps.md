# IAM User Admin và MFA
### Accout IAM Admin - MFA
1. Chúng ta sẽ có một devide bên ngoài, device sẽ nhận và cho ra một số id và dựa vào số id đó để nhập vào yêu cầu của AWS mỗi lần đăng nhập
Tránh trường hợp hacker có thể đăng nhập vào sử dụng resource

2. Nhấn đăng nhập vào bảng điều khiển -> chọn Sign in using root user email (điền tài khoản gmail -> nhấn next và điền mật khẩu)

3. Search (IAM) chọn IAM mở với tab mới -> sẽ thấy Dashboard -> bên thanh Side Bar sẽ thấy list danh sách -> chọn Users -> Create User -> User name (điền vào ô input Admin_User_DevOps và tích chọn Provide user access to the AWS Management Console -> chọn i want to create an IAM user và tích chọn Users must create a new password at next sign-in-Recommended để không tạo lại password) -> Create

4. Set permissions trong Permissions options có thể chọn Add user to group và gán quyền AdministratorAccess sau này có thể tích bỏ AdministratorAccess cũng được hoặc có thể chọn thẳng Attach policies directly -> tích chọn AdministratorAccess -> Next

5. Review and create -> tích chọn Create User 

6. Retrieve password -> sẽ thấy phần user và password và đường link console(lấy id trong phần đường link này) -> qua tab khác đăng nhập bằng tài khoản và id vừa được tạo

7. Sau khi đăng nhập xong sẽ thấy Console Home -> nếu muốn bật xác thực thì chọn Security Credential -> chọn asign MFA -> trong Device name tự đặt (ví dụ AWS-lab-AdminuserDevOps) -> chọn Authenticator app -> Next (Có thể không cần cũng được)
-------------------------------------------------------------------------------------------------------------------

# Quản lý chi phí với AWS Budgets
1. Đăng nhập với User Root

2. Tích chọn vào Billing and Cost Management và sẽ thấy Tích chọn vào Billing and Cost Management home

3. Click vào Budgets bên thanh sidebar -> create budgets -> click chọn use a template -> kéo xuống Enter your budgeted amount($) ví dụ là 10 đô -> kéo xuống Email recipients (điền mail của mình vào) -> Create budget

# Tổng quan  các loại dịch vụ trên AWS

# Khởi tạo EC2 Ubuntu với VPC default
1. Gần thanh Header click chọn vào EC2 -> click chọn vào instances -> tích chọn Launch instances bên thanh sidebar

2. Name đặt là EC2_Ubuntu

3. Quick Start (click chọn Ubuntu)

4. Key pair name - required (đặt tên instance_Key_DevOps_On_AWS) -> Create key pair -> trong thư mục được tải về

5. Security group name - required (sg_for_devops_on_aws)

6. configure storage (1x tăng lên 18) 

7. click launch instance để tạo máy chủ

8. vào visual code kéo thư mục key đã được download vào thư mục visualcode -> sau đó ssh -i instance_Key_DevOps_On_AWS.pem ubuntu@ip của server (truy cập thành công vào server)

# Triển khai một VPC mới (là network là nơi tạo các resource bên trong)

1. Trên thanh header tích chọn VPC

2. Vào VPCs để xem sơ đồ của network

3. click chọn vào Create VPC gần thanh header

4. ở Resources to create (chọn VPC and more)

5. Sửa Auto-generate thành (devops)

6. Click Create VPC 

7. Sau khi cài xong nhấn vào (View VPC)

# Khởi tạo EC2 tên VPC mới

1. Chọn launch instance trong dashboard 

2. Name and tags (EC2_Ubuntu)

3. Quick Start (click chọn Ubuntu)

4. Key pair name - required (đặt tên instance_Key_DevOps_On_AWS) -> Create key pair

5. VPC - required (thay đổi thành devops-vpc bài trước đã tạo)

6. Subnet chọn devops-subnet-public2

7. Auto-assign public IP (chọn Enable)

8. Security group name - required (devops_sg)

9. configure storage (1x tăng lên 18) 

10. click launch instance để tạo máy chủ

# Hướng dẫn Connect tới Database và thao tác
1. Vào Databases bên thanh Sidebar của Dashboard -> sẽ thấy database devops-2 đã được tạo -> click vào 
* Chú ý Endpoint trong phần Endpoint & port
* Bên cạnh sẽ thấy Security -> chọn vào default (sg-07bb862d092e3b2c2) ở VPC security groups -> nếu chưa có hãy mở bằng Edit inbound rules

2. SSH vào server EC2 // ssh -i tới thư mục chứac key ubuntu@ip

3. sudo apt update

4. sudo apt install postgresql postgresql-contrib

5. sudo systemctl start postgresql.service

6. PGPASSWORD=vuduyduc psql -h <endpoint> -p 5432 -U postgres -d postgres

## Vào Security Group đang gắn → Thêm Inbound Rule:

1. sudo apt update

2. sudo apt install mysql-client -y

3. mysql -h <RDS-endpoint> -u admin -p

# Làm quen với dịch vụ lưu trữ S3

1. Vào Dashboard Console Home -> nhấn vào S3 

2. Sau khi chuyển tới dashboard S3 
- nhấn vào create bucket
- Bucket name (đặt là lab2.12-devops) 
- tất cả còn lại để mặc định 
- Createa bucket

3. Sau khi tạo xong vào lại 
- lab2.12-devops 
- Create folder 
- đặt tên Folder(data) 
- Create Folder 
- sau khi tạo xong sẽ xuất hiện folder data 
- click upload 
- click vào Add files 
- chọn file 
- upload
- vào ảnh vừa upload sẽ thấy Object URL sẽ thấy đường link ảnh

4. vào lại lab2.12-devops 
- sẽ hấy Permissions 
- ở phần Block public access 
- nhấn Edit 
- bỏ tích chọn Block all public access 
- save changes 
- kéo xuống tìm Accees control list (ACL) chọn edit
- chọn ACLs enabled 
- save changes

5. Vào lại lab2.12-devops 
- vào thư mục data 
- tích chọn ảnh 
- chọn Actions phía trên (chọn Make public using ACL) 
- make public 
- truy cập lại URL ảnh

# Dùng git làm việc với source 

``` bash
git config --list
git clone <repository-url>  
git status                  # Kiểm tra trạng thái
git add .                   # Thêm file vào staging
git commit -m "Message"     # Commit thay đổi
git pull origin <branch>    # Lấy code mới nhất từ remote
git push origin <branch>    # Đẩy code lên remote
git checkout <branch-name>  # Chuyển sang nhánh 
git checkout -b <branch>    # Tạo và chuyển sang nhánh mới
git merge <branch>          # Hợp nhánh
git fetch                   # Lấy thông tin từ remote (không merge)
git log                     # Check log 
git branch -d <branch-name> # Xóa nhánh đã merge
git push origin --delete develop # push thay doi 
git branch -D <branch-name> # Xóa nhánh chưa merge
```

# Các thao tác cơ bản với Docker

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
docker run -d --name <container-name> <image-name>:<tag>

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
```

# Build images với Dockerfile

### Setup environment
``` bash
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
apt-get install nodejs -y
sudo npm install -g npm@latest
npm i -g @nestjs/cli
nest new nest-docker
cd nest-docker
nano Dockerfile
```

### Dockerfile
``` bash
# Use the official Node.js image as the base image
FROM node:20
	
# Set the working directory inside the container
WORKDIR /usr/src/app
	
# Copy package.json and package-lock.json to the working directory
COPY package*.json ./
	
# Install the application dependencies
RUN npm install
	
# Copy the rest of the application files
COPY . .
	
# Build the NestJS application
RUN npm run build
	
# Expose the application port
EXPOSE 3000
	
# Command to run the application
CMD ["node", "dist/main"]
```

### run docker container
``` bash
docker build -t nest-docker:v1 .
docker run -d -p 3000:3000 nest-docker 

# push lên dockerhub
docker login
docker tag nest-docker vuduyduc764/nest-docker
docker images
docker push vuduyduc764/nest-docker
```

# Quản lý container với docker-compose

- nano docker-compose.yml

``` bash 
version: '3.8'

services:
  app:
    build: .
    container_name: nest-docker
    ports:
      - "3000:3000"
    volumes:
      - /storage:/app
    environment:
      - NODE_ENV=development
      - DATABAE_URL=0
    depends_on:
      - db

  db:
    image: mongo:6
    container_name: mongodb
    ports:
      - "27017:27017"
    volumes:
      - mongo_data:/data/db
	
volumes:
  mongo_data:
```

### run docker-compose and down docker-compose
``` bash
docker-compose -f docker-compose.yaml up -d
docker-compose down
```

# Setup Terraform

### install terraform và hashicorp

``` bash
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common

wget -O- https://apt.releases.hashicorp.com/gpg | \
gpg --dearmor | \
sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null

gpg --no-default-keyring \
--keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg \
--fingerprint

echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

sudo apt update
sudo apt-get install terraform
```

### install aws 

``` bash 
sudo apt install unzip
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
aws --version
```

### configure aws

``` bash
aws configure

### điền thông tin key
Access Key ID: <you-access-key-id>
Secret Access Key: <your-secret-key-access>
region name: <your-region>
output format: json
```

# Làm quen với Terraform

### tạo thư mục làm việc 

``` bash
mkdir terraform
cd terraform
```

### Các câu lệnh để kiểm tra vpc, subnet
``` bash
aws ec2 describe-security-groups --query "SecurityGroups[*].[GroupId,GroupName]" --output table
aws ec2 describe-subnets --query "Subnets[*].[SubnetId,AvailabilityZone]" --output table
```

### Cấu trúc file bên trong

``` bash
nano variables.tf

# nội dung bên trong
variable "region" {
  description = "Region"
  type        = string
  default     = "ap-southeast-1"
}

variable "ami" {
  description = "ami"
  type        = string
  default     = "ami-0474ac020852b87a9"
}

variable "instance_type" {
  description = "instance_type"
  type        = string
  default     = "t2.micro"
}
```

``` bash
nano version.tf

### nội dung bên trong
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.86.0"
    }
  }
	
  required_version = ">= 1.0"
}

provider "aws" {
  region  = var.region
}
```

``` bash
nano main.tf

### nội dung bên trong
resource "aws_instance" "app_server" {
  ami           = var.ami
  instance_type = var.instance_type

  tags = {
    Name = "ExampleAppServerInstance"
  }
}
```

``` bash
nano outputs.tf

# nội dung bên trong
output "public_ip" {
  value = aws_instance.app_server.public_ip
}
```

### các câu lệnh chạy

``` bash
terraform plan
terraform init
terraform apply --auto-approve

# dùng để destroy
terraform destroy --auto-approve
```

# set up ECR chứa các docker images 

### install docker

``` bash
mkdir tools 
cd tools 
mkdir install-docker
cd install-docker
nano install-docker.sh
```

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

``` bash
chmod +x install-docker.sh
bash install-docker.sh
```

### Setup repo docker

1. Tạo ECR Repository trên AWS

2. vafo AWS Console -> tìm ECR

3. Chọn create repostiory
* Đặt tên repo (ví dụ: my-service).
* Chọn Private (thường dùng).
* Các tuỳ chọn khác để mặc định.

4. Sau khi tạo xong, sẽ có 1 repo dạng <aws_account_id>.dkr.ecr.<region>.amazonaws.com/my-service

### install aws 

``` bash 
sudo apt install unzip
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
aws --version
```

### configure aws

``` bash
aws configure

### điền thông tin key
Access Key ID: <you-access-key-id>
Secret Access Key: <your-secret-key-access>
region name: <your-region>
output format: json
```

### Đăng nhập từ ECR từ Docker
- aws ecr get-login-password --region <region> | docker login --username AWS --password-stdin <aws_account_id>.dkr.ecr.<region>.amazonaws.com

### build 1 docker images

- Phải có Dockerfile cho service 

``` bash
cd backend-folder
docker build -t backend-service . 

# rename docker images vừa build xong 
docker tag backend-service:latest <aws_account_id>.dkr.ecr.<region>.amazonaws.com/my-service:latest

# push lên ECR 
docker push <aws_account_id>.dkr.ecr.<region>.amazonaws.com/my-service:latest
```

# Deploy ứng dụng với ecs

1. Tạo Cluster ECS

* Vào AWS Console → ECS → Clusters → Create Cluster.

* Đặt tên cluster (vd: nestjs-cluster).

2. Tạo Task Definition

* Vào ECS → Task Definitions → Create new Task Definition

* Đặt tên task (vd: nestjs-task)

* Thêm Container definition
- Name: nestjs-service
- Image: <aws_account_id>.dkr.ecr.<region>.amazonaws.com/my-service:latest
- Port mappings: 3000 → 3000 (hoặc 80 → 3000 nếu muốn expose HTTP)

* Chọn CPU/RAM (vd: 0.5 vCPU, 1GB RAM)

3. Tạo Service để chạy Task

* Vào ECS → Clusters → Chọn cluster → Create service.

* Task Definition: chọn cái vừa tạo (nestjs-task)

* Number of tasks: ví dụ 1.

* Networking:
- Chọn VPC.
- Chọn Subnet.
- Security group: mở port 3000 (hoặc 80).

4. Triển khai

* Nhấn Create service → ECS sẽ tự pull image từ ECR và chạy container.

* Bạn có thể kiểm tra trong ECS → Cluster → Tasks.