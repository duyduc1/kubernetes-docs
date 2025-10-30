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

curl -LO "https://dl.k8s.io/release/$(curl -Ls https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

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

### Bước 03: Triển khai Helmchart

- Nếu dùng nginx-ingress

``` bash
wget https://get.helm.sh/helm-v3.16.2-linux-amd64.tar.gz
tar xvf helm-v3.16.2-linux-amd64.tar.gz
sudo mv linux-amd64/helm /usr/bin/
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm search repo nginx
helm pull ingress-nginx/ingress-nginx
tar -xzf ingress-nginx-4.13.2.tgz

cp -rf ingress-nginx /home/ubuntu
kubectl create ns ingress-nginx
helm -n ingress-nginx install ingress-nginx -f ingress-nginx/values.yaml ingress-nginx
helm version
kubectl get all -n ingress-nginx
```
- Nếu dùng alb-controller

``` bash
curl -o iam_policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.7.2/docs/install/iam_policy.json
aws iam create-policy --policy-name AWSLoadBalancerControllerIAMPolicy --policy-document file://iam_policy.json

eksctl create iamserviceaccount \
  --cluster=<cluster-name> \
  --namespace=kube-system \
  --name=aws-load-balancer-controller \
  --role-name=AmazonEKSLoadBalancerControllerRole \
  --attach-policy-arn=arn:aws:iam::<ACCOUNT-ID>:policy/AWSLoadBalancerControllerIAMPolicy \
  --approve \
  --region=<region>

# ví dụ
eksctl create iamserviceaccount \
  --cluster=eksdemo3 \
  --namespace=kube-system \
  --name=aws-load-balancer-controller \
  --role-name=AmazonEKSLoadBalancerControllerRole \
  --attach-policy-arn=arn:aws:iam::173534767781:policy/AWSLoadBalancerControllerIAMPolicy \
  --approve \
  --region=us-east-1
```

``` bash
wget https://get.helm.sh/helm-v3.16.2-linux-amd64.tar.gz
tar xvf helm-v3.16.2-linux-amd64.tar.gz
sudo mv linux-amd64/helm /usr/bin/

helm repo add eks https://aws.github.io/eks-charts
helm repo update
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=<cluster-name> \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller \
  --set region=<region> \
  --set vpcId=<vpc-id>

# ví dụ
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=eksdemo3 \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller \
  --set region=us-east-1 \
  --set vpcId=vpc-06cb2d99ad1a50f3b

# kiểm tra
kubectl get deployment -n kube-system aws-load-balancer-controller
```

# Triển khai ứng dụng trên EKS

## Tạo namespace và resouce cho namespace đó

``` bash
mkdir project
cd project
```

``` bash
nano ns-frontend.yaml

# nội dung bên trong
apiVersion: v1
kind: Namespace
metadata:
  name: frontend-resource
```

``` bash
nano resourcequota-frontend.yml

# nội dung bên trong
apiVersion: v1
kind: ResourceQuota
metadata:
  name: mem-cpu-quota
  namespace: frontend-resource
spec:
  hard:
    requests.cpu: "2"
    requests.memory: 4Gi
    limits.cpu: "4"
    limits.memory: "8Gi"
```

### Apply cấu hình

``` bash
kubectl apply -f ns-frontend.yaml
kubectl apply -f resourcequota-frontend.yaml
```

### Xoá cấu hình 

``` bash
kubectl delete -f ns-frontend.yaml
kubectl delete -f resourcequota-frontend.yaml
```

## Triển khai Deployment/Service/Ingress

### Dự án frontend

``` bash
nano frontend.yaml

# nội dung bên trong 
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend-deployment
  namespace: frontend-resource
  labels:
    app: frontend
spec:
  replicas: 2
  selector:
    matchLabels:
      app: frontend
  template:
    metadata:
      labels:
        app: frontend
    spec:
      containers:
        - name: frontend
          image: your-dockerhub-user/frontend:latest
          imagePullPolicy: Always
          ports:
            - containerPort: 80
              name: tcp
              protocol: TCP

---
apiVersion: v1
kind: Service
metadata:
  name: frontend-service
  namespace: frontend-resource
spec:
  type: ClusterIP   
  selector:
    app: frontend
  ports:
    - name: tcp
      port: 80
      protocol: TCP
      targetPort: 80
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: frontend-ingress
  namespace: frontend-resource
  # sử dụng alb-controller
  annotations:
    kubernetes.io/ingress.class: alb
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: ip
  # sử dụng nginx-ingress
  annotations:
    kubernetes.io/ingress.class: nginx
spec:
  # dùng cho alb-controller
  ingressClassName: alb
  # dùng cho nginx-ingress
  ingressClassName: nginx
  rules:
  - host: myapp-frontend.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: frontend-service
            port:
              number: 80

```

### Triển khai và kiểm tra

``` bash
# Triển khai dự án
kubectl apply -f frontend.yaml

# Kiểm tra Pods
kubectl get pods -n frontend

# Kiểm tra Service
kubectl get svc -n frontend

# Kiểm tra Ingress
kubectl get ingress -n frontend
```

### Dự án backend

``` bash
nano ns-backend.yaml

# nội dung bên trong
apiVersion: v1
kind: Namespace
metadata:
  name: backend-resource
```

``` bash
nano resourcequota-backend.yml

# nội dung bên trong
apiVersion: v1
kind: ResourceQuota
metadata:
  name: mem-cpu-quota
  namespace: backend-resource
spec:
  hard:
    requests.cpu: "2"
    requests.memory: 4Gi
    limits.cpu: "4"
    limits.memory: "8Gi"
```

### Apply cấu hình

``` bash
kubectl apply -f ns-backend.yaml
kubectl apply -f resourcequota-backend.yaml
```

### Xoá cấu hình 

``` bash
kubectl delete -f ns-backend.yaml
kubectl delete -f resourcequota-backend.yaml
```

## Triển khai Deployment/Service/Ingress

### Dự án backend

``` bash
nano user-service-config.yaml

# Nội dung bên trong
apiVersion: v1
kind: ConfigMap
metadata:
  name: user-service-config
  namespace: backend-resource
data:
  application.properties: |
    spring.datasource.url=jdbc:mysql://<IP-SERVER>:3306/userdb
    spring.datasource.username=user
    spring.datasource.password=userpass
    spring.datasource.driverClassName=com.mysql.cj.jdbc.Driver

```

``` bash
nano backend.yaml

# nội dung bên trong 
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend-deployment
  namespace: backend-resource
  labels:
    app: backend
spec:
  replicas: 2
  selector:
    matchLabels:
      app: backend
  template:
    metadata:
      labels:
        app: backend
    spec:
      containers:
        - name: backend
          image: your-dockerhub-user/backend:latest
          imagePullPolicy: Always
          ports:
            - containerPort: 8080
              name: tcp
              protocol: TCP
          volumeMounts:
            - name: config-volume
              mountPath: /config/application.properties   
              subPath: application.properties
      volumes:
      - name: config-volume
        configMap:
          name: user-service-config

---
apiVersion: v1
kind: Service
metadata:
  name: backend-service
  namespace: backend-resource
spec:
  type: ClusterIP   
  selector:
    app: backend
  ports:
    - name: tcp
      port: 8080
      protocol: TCP
      targetPort: 8080
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: backend-ingress
  namespace: backend-resource
  # nếu muốn dùng alb-controller
  annotations:
    kubernetes.io/ingress.class: alb
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: ip
  # nếu dùng nginx-ingress
  annotations:
    kubernetes.io/ingress.class: alb
spec:
  # dùng cho alb-controller
  ingressClassName: alb
  # dùng cho nginx-ingress
  ingressClassName: nginx
  rules:
  - host: myapp-backend.com
    http:
      paths:
      - path: /api
        pathType: Prefix
        backend:
          service:
            name: backend-service
            port:
              number: 8080
```

### Triển khai và kiểm tra

``` bash
# Apply lên EKS
kubectl apply -f user-service-config.yaml

# Kiểm tra
kubectl get configmap -n backend-resource

# Triển khai dự án
kubectl apply -f backend.yaml

# Kiểm tra Pods
kubectl get pods -n backend

# Kiểm tra Service
kubectl get svc -n backend

# Kiểm tra Ingress
kubectl get ingress -n backend
```

# file Deploy cho backend-micro

``` bash
nano ns-micro.yaml

# nội dung bên trong
apiVersion: v1
kind: Namespace
metadata:
  name: backend-micro
```

``` bash
nano resourcequota-micro.yml

# nội dung bên trong
apiVersion: v1
kind: ResourceQuota
metadata:
  name: mem-cpu-quota
  namespace: backend-micro
spec:
  hard:
    requests.cpu: "2"
    requests.memory: 4Gi
    limits.cpu: "4"
    limits.memory: "8Gi"
```

### Apply cấu hình

``` bash
kubectl apply -f ns-micro.yaml
kubectl apply -f resourcequota-micro.yaml
```

### Xoá cấu hình 

``` bash
kubectl delete -f ns-micro.yaml
kubectl delete -f resourcequota-micro.yaml
```

## Triển khai Deployment/Service/Ingress

### Dự án backend-micro

``` bash
nano user-service-config.yaml

# Nội dung bên trong
apiVersion: v1
kind: ConfigMap
metadata:
  name: user-service-config
  namespace: backend-micro
data:
  application.properties: |
    spring.datasource.url=jdbc:mysql://<ip-server>:3306/userdb
    spring.datasource.username=user
    spring.datasource.password=userpass
    spring.datasource.driverClassName=com.mysql.cj.jdbc.Driver
```

``` bash
nano order-service-config.yaml

# Nội dung bên trong
apiVersion: v1
kind: ConfigMap
metadata:
  name: order-service-config
  namespace: backend-micro
data:
  application.properties: |
    spring.datasource.url=jdbc:mysql://<IP-SERVER>:3306/orderdb
    spring.datasource.username=order
    spring.datasource.password=order
    spring.datasource.driverClassName=com.mysql.cj.jdbc.Driver
```

``` bash
nano product-service-config.yaml

# Nội dung bên trong
apiVersion: v1
kind: ConfigMap
metadata:
  name: product-service-config
  namespace: backend-micro
data:
  application.properties: |
    spring.datasource.url=jdbc:mysql://<IP-SERVER>:3306/productdb
    spring.datasource.username=product
    spring.datasource.password=product
    spring.datasource.driverClassName=com.mysql.cj.jdbc.Driver
```

``` bash
nano payment-service-config.yaml

# Nội dung bên trong
apiVersion: v1
kind: ConfigMap
metadata:
  name: payment-service-config
  namespace: backend-micro
data:
  application.properties: |
    spring.datasource.url=jdbc:mysql://<IP-SERVER>:3306/paymentdb
    spring.datasource.username=payment
    spring.datasource.password=payment
    spring.datasource.driverClassName=com.mysql.cj.jdbc.Driver
```

## File deploy dự án micro

``` bash
nano micro-backend.yml

apiVersion: apps/v1
kind: Deployment
metadata:
  name: user-deployment
  namespace: backend-micro
  labels:
    app: user
spec:
  replicas: 2
  selector:
    matchLabels:
      app: user
  template:
    metadata:
      labels:
        app: user
    spec:
      containers:
        - name: user
          image: your-dockerhub-user/user-service:latest
          imagePullPolicy: Always
          ports:
            - containerPort: 8081
              name: tcp
              protocol: TCP
          volumeMounts:
            - name: config-volume
              mountPath: /config/application.properties   
              subPath: application.properties
      volumes:
      - name: config-volume
        configMap:
          name: user-service-config
---
apiVersion: v1
kind: Service
metadata:
  name: user-service
  namespace: backend-micro
spec:
  selector:
    app: user
  ports:
    - name: tcp
      port: 8081
      protocol: TCP
      targetPort: 8081
  type: ClusterIP

apiVersion: apps/v1
kind: Deployment
metadata:
  name: order-deployment
  namespace: backend-micro
  labels:
    app: order
spec:
  replicas: 2
  selector:
    matchLabels:
      app: order
  template:
    metadata:
      labels:
        app: order
    spec:
      containers:
        - name: order
          image: your-dockerhub-user/order-service:latest
          imagePullPolicy: Always
          ports:
            - containerPort: 8082
              name: tcp
              protocol: TCP
          volumeMounts:
            - name: config-volume
              mountPath: /config/application.properties   
              subPath: application.properties
      volumes:
      - name: config-volume
        configMap:
          name: order-service-config
---
apiVersion: v1
kind: Service
metadata:
  name: order-service
  namespace: backend-micro
spec:
  selector:
    app: order
  ports:
    - name: tcp
      port: 8082
      protocol: TCP
      targetPort: 8082
  type: ClusterIP

apiVersion: apps/v1
kind: Deployment
metadata:
  name: product-deployment
  namespace: backend-micro
  labels:
    app: product
spec:
  replicas: 2
  selector:
    matchLabels:
      app: product
  template:
    metadata:
      labels:
        app: product
    spec:
      containers:
        - name: product
          image: your-dockerhub-user/product-service:latest
          imagePullPolicy: Always
          ports:
            - containerPort: 8083
              name: tcp
              protocol: TCP
          volumeMounts:
            - name: config-volume
              mountPath: /config/application.properties   
              subPath: application.properties
      volumes:
      - name: config-volume
        configMap:
          name: product-service-config
---
apiVersion: v1
kind: Service
metadata:
  name: product-service
  namespace: backend-micro
spec:
  selector:
    app: product
  ports:
    - name: tcp
      port: 8083
      protocol: TCP
      targetPort: 8083
  type: ClusterIP

apiVersion: apps/v1
kind: Deployment
metadata:
  name: payment-deployment
  namespace: backend-micro
  labels:
    app: payment
spec:
  replicas: 2
  selector:
    matchLabels:
      app: payment
  template:
    metadata:
      labels:
        app: payment
    spec:
      containers:
        - name: payment
          image: your-dockerhub-user/payment-service:latest
          imagePullPolicy: Always
          ports:
            - containerPort: 8084
              name: tcp
              protocol: TCP
          volumeMounts:
            - name: config-volume
              mountPath: /config/application.properties   
              subPath: application.properties
      volumes:
      - name: config-volume
        configMap:
          name: payment-service-config
---
apiVersion: v1
kind: Service
metadata:
  name: payment-service
  namespace: backend-micro
spec:
  selector:
    app: payment
  ports:
    - name: tcp
      port: 8084
      protocol: TCP
      targetPort: 8084
  type: ClusterIP

apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: backend-ingress
  namespace: backend-micro
  # nếu muốn dùng alb-controller
  annotations:
    kubernetes.io/ingress.class: alb
    alb.ingress.kubernetes.io/scheme: internet-facing
  # nếu dùng nginx-ingress
  annotations:
    kubernetes.io/ingress.class: alb
spec:
  # dùng cho alb-controller
  ingressClassName: alb
  # dùng cho nginx-ingress
  ingressClassName: nginx
  rules:
  - host: api.myapp.com
    http:
      paths:
      - path: /api/users
        pathType: Prefix
        backend:
          service:
            name: user-service
            port:
              number: 8081
      - path:/api/orders
        pathType: Prefix
        backend:
          service:
            name: order-service
            port:
              number: 8082
      - path: /api/products
        pathType: Prefix
        backend:
          service:
            name: product-service
            port:
              number: 8083
      - path: /api/payments
        pathType: Prefix
        backend:
          service:
            name: payment-service
            port:
              number: 8084
```

### Triển khai và kiểm tra
``` bash
# Apply configmap lên EKS
kubectl apply -f user-service-config.yaml
kubectl apply -f order-service-config.yaml
kubectl apply -f products-service-config.yaml
kubectl apply -f payment-service-config.yaml

# Kiểm tra
kubectl get configmap -n backend-micro

# Triển khai dự án
kubectl apply -f micro-backend.yaml

# Kiểm tra Pods
kubectl get pods 

# Kiểm tra Service
kubectl get svc 

# Kiểm tra Ingress
kubectl get ingress
```

### destroy cụm k8s bằng câu lệnh

``` bash
eksctl delete cluster --name <cluster-name> --region <region>

# ví dụ
eksctl delete cluster --name my-eks-cluster --region ap-southeast-1
```

### Có thể dùng CloudFormation trên AWS để xem các stack còn chạy không
