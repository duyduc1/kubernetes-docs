# Triển khai 1 cụm Kubernetes EKS
### Yêu cầu cài đặt 
- AWS CLI
- eksctl
- aws Configure

### Cài đặt AWS CLI và cấu hình aws Configure
``` bash
apt install unzip
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
aws configure
- Access Key ID: AWWEQKOOKKL1K3123K8Y55]
- Secret Access Key: asqwnvbnrtr123ZaGVwsdnfsQWE/T/
- region name: ap-southeast-1
- output format: json
```

### Cài đặt eksctl
``` bash
sudo apt update && sudo apt upgrade -y
curl -sSL "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" -o eksctl.tar.gz

tar -xvzf eksctl.tar.gz

sudo mv eksctl /usr/local/bin/

rm eksctl.tar.gz

eksctl version

curl -LO "https://dl.k8s.io/release/$(curl -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

chmod +x kubectl
sudo mv kubectl /usr/local/bin/

kubectl version --client
```

### Tạo cụm EKS và Nhóm node

## Bước 00: Giới thiệu
1. Hiểu về các thành phần cốt lõi của EKS
- Control Plane 
- Worker Nodes và nhóm Node
- Fargate Profiles
- VPC

2. Tạo cụm EKS
3. Liên kết cụm EKS với IAM OIDC Provider
4. Tạo nhóm Node cho EKS
5. Kiểm tr cụm, nhómNode, EC2 instances, IAM Policies và nhóm Node

## Cập nhât Access key
``` bash
export AWS_ACCESS_KEY_ID=YOUR_ACCESS_KEY
export AWS_SECRET_ACCESS_KEY=YOUR_SECRET_KEY
export AWS_REGION=ap-southeast-1
```

## Bước 01: Tạo cụm EKS bằng eksctl
- Quá trình tao Control Plane của cụm sẽ mất khoảng 15-20 phút

``` bash
eksctl create cluster --name=eksdemo3 \
                      --region=ap-southeast-1 \
                      --zones=ap-southeast-1a,ap-southeast-1b \
                      --without-nodegroup \
                      --version=1.33

eksctl get cluster                  
```

## Bước 02: Tạo & Liên kết IAM OIDC Provider cho cụm EKS
- Để sử dụng IAM roles cho tài khoản dịch vụ Kubernetes trên cụm EKS, chúng ta cần tạo và liên kết OIDC identity provider.
- Sử dụng lệnh eksctl sau:

``` bash
# Mẫu lệnh
eksctl utils associate-iam-oidc-provider \
    --region region-code \
    --cluster <cluster-name> \
    --approve

# Thay thế bằng region & tên cụm
eksctl utils associate-iam-oidc-provider \
    --region ap-southeast-1 \
    --cluster eksdemo3 \
    --approve
```

## Bước 03: Tạo Keypair EC2
- Tạo một EC2 Keypair mới có tên Instance_Key_DevOps_On_AWS
- Sử dụng keypair này khi tạo nhóm Node của EKS.
- Keypair này sẽ giúp chúng ta đăng nhập vào Worker Nodes của EKS thông qua Terminal.

## Bước 04: Tạo nhóm Node với các Add-Ons bổ sung trong Public Subnets
- Các add-ons này sẽ tự động tạo IAM policies cho chúng ta trong vai trò nhóm Node.

``` bash
# Tạo nhóm Node Public   
eksctl create nodegroup --cluster=eksdemo3 \
                        --region=ap-southeast-1 \
                        --name=eksdemo3-ng-public1 \
                        --node-type=t2.micro \
                        --nodes=2 \
                        --nodes-min=2 \
                        --nodes-max=4 \
                        --node-volume-size=50 \
                        --ssh-access \
                        --ssh-public-key=Instance_Key_DevOps_On_AWS \
                        --managed \
                        --asg-access \
                        --external-dns-access \
                        --full-ecr-access \
                        --appmesh-access \
                        --alb-ingress-access 
``` 

## Bước 05: Kiểm tra cụm & Nodes
### Kiểm tra subnet nhóm Node để xác nhận EC2 Instances ở Public Subnet
- Vào Services -> EKS -> eksdemo -> eksdemo3-ng-public1
- Nhấp vào Associated subnet trong tab Details
- Chuyển sang tab Route Table
- Kiểm tra xem route internet có thông qua Internet Gateway (0.0.0.0/0 -> igw-xxxxxxxx)

### Kiểm tra cụm, nhóm Node trong EKS Management Console
- Vào Services -> Elastic Kubernetes Service -> eksdemo

### Liệt kê các Worker Nodes
``` bash
# Liệt kê cụm EKS
eksctl get cluster

# Liệt kê nhóm Node trong cụm
eksctl get nodegroup --cluster=<clusterName>

# Cập nhật kubeconfig
aws eks update-kubeconfig --region ap-southeast-1 --name eksdemo3

# Liệt kê Nodes trong cụm Kubernetes hiện tại
kubectl get nodes -o wide

# Xem kubeconfig hiện tại
kubectl config view --minify
```

### Kiểm tra IAM Role và danh sách Policies của Worker Node
- Vào Services -> EC2 -> Worker Nodes
- Nhấp vào IAM Role liên kết với Worker Nodes

### Kiểm tra Security Group liên kết với Worker Nodes
- Vào Services -> EC2 -> Worker Nodes
- Nhấp vào Security Group liên kết với EC2 Instance chứa remote trong tên.

### Kiểm tra CloudFormation Stacks
- Kiểm tra Control Plane Stack & Events
- Kiểm tra NodeGroup Stack & Events

### Đăng nhập vào Worker Node bằng Keypair kube-demo
``` bash
ssh -i Instance_Key_DevOps_On_AWS.pem ec2-user@<Public-IP-of-Worker-Node>
```

## Bước 06: Xoá cụm EKS và Nhóm Node
- Chú ý: Xóa hết các workload đã deploy để qúa trình xóa clsuter nhanh hơn, không bị treo
- Xóa hết các namespace đã dùng, cả workload của ns default

### Bước 1 : Xoá nhóm Node
``` bash
# Liệt kê cụm EKS
eksctl get clusters

Xóa hết các namespace đã dùng, cả workload của ns default

# Lấy tên nhóm Node
eksctl get nodegroup --cluster=<clusterName>
eksctl get nodegroup --cluster=eksdemo3

# Xóa nhóm Node
eksctl delete nodegroup --cluster=<clusterName> --name=<nodegroupName>
eksctl delete nodegroup --cluster=eksdemo3 --name=eksdemo3-ng-public1
```

### Bước 02: Xóa cụm
``` bash
# Xóa cụm
eksctl delete cluster <clusterName>
eksctl delete cluster eksdemo3
```