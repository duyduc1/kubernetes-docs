# Triển khai kubernetes trên nền tảng GCP (GKE)

1. vào 3 thanh sọc -> kubernetes Engine -> Clusters -> Create -> Standard:you manage Your Cluster(Configure)

2. Sau đó sẽ thấy  (Cluster basics) -> đặt tên (Cluster) theo dự án hoặc môi trường -> Zone(asia-northeast1-c) -> target release channel (regular) // đừng vội nhấn create

3. Sang tab (Fleet registration) // chưa cần thiết nên không chọn gì

4. Chọn Default-pool ( để mặc định ) -> nodes -> image type -> Ubuntu with containerd

- Networking ( để mặc định )

- Security ( để mặc định )

- Metadata -> Kubernetes lables -> ADD KUBERNETS LABEL ( key 1 : env , value : develop )

- Cluster -> Tất cả đều đều mặc định 

- Create

5. Sau khi dựng xong chọn CONNECT 

- sau đó enter để xác thực kết nối 

- kubectl get node -o wide

# Cài đặt Rancher trên cloud

1. Chọn Computer Engine -> VM instances -> Create instances
					
* Name (đặt là rancher-server) 
				
* Region (chọn asia-notheast1(Tokyo)) - Zone ( asia-notheast1-c)

* Availability polices -> VM provisioning model (chọn Standard)

2. qua Task Machine configuration 

* Machine type -> PRESET (es-small(2 vCPU, 1 core , 2GB memory)) // tiết kiện chi phí

3. qua Task OS and storage -> nhấn CHANGE (có thể thay đổi disk hoặc không)

- Chọn ADD NEW DISK 
		
- Name (đặt disk-mount-data-rancher hoặc tên khác)

- Disk source type (Blank disk)

- Size (40GB) -> Save

4. qua Task Networking 
					
* Firewall -> tích chọn Allow HTTP traffic && Allow HTTPS traffic -> CREATE

### Truy cập vào server

1. cài đặt rancher

``` bash
sudo -i
apt update -y
apt install docker.io docker-compose
lsblk
sudo mkfs.ext4 -m 0 /dev/sdb
mkdir /data
echo "/dev/sdb  /data  ext4  defaults  0  0" | sudo tee -a /etc/fstab
mount -a
df -h

docker run --name rancher-server -d --restart=unless-stopped -p 80:80 -p 443:443 -v /data/rancher:/var/lib/rancher --privileged rancher/rancher:v2.9.2

docker logs  rancher-server  2>&1 | grep "Bootstrap Password:" # lấy password
```

2. Setup Rancher

- vào google truy cập https://ip của server

- dán passworld vừa lấy được vào trong web Rancher

- chọn Set a specific password to use // dùng để setup passworld mới

- New Password

- Confirem New Password
				
- Tích chọn By checking the box , you accept the End User -> Saving
	
- Vào dashboard của Rancher -> ở thanh 3 sọc -> chọn VPC Network -> chọn RESERVE EXTERNAL STATIC IP ADDRESS -> kéo xuống  Attached to (gõ tìm rancher-server)
	
- có thể không dùng IP STATIC cũng được 

### trên Dashboard rancher 

1. chọn Import Existing -> chọn Generic -> Cluster Name (là cụm K8s của mình ví dụ Devopsk8s) -> Create 

2. Coppy dòng thứ 2 (nếu SSL là tự ký hoặc không đủ tin tưởng) || Coppy dòng thứ 1 (nếu có SSL và SSL đủ tin tưởng)

3. Vào server k8s-master-1 và paste dòng lệnh đã copy ở trên vào 

4. để theo dõi sau khi paster dòng lệnh vào dùng calina

``` bash
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.0/manifests/calico.yaml
kubectl get pods -n kube-system | grep calico
watch kubectl get pod -n kube-system
```

* Vào lại web Rancher sẽ lấy trạng thái pending chuyển thành waiting 

* chờ một vài phút sau đó nhấn vào Machine Pools sẽ lấy các cụm k8s đã được tạo

* Ra home sẽ thấy một cụm Devopsk8s nhấn vào và coi thông tin (các Pods , CPU , Memory)

# Pod K8S

- Pod là đơn vị triển khai nhỏ nhất và đơn giãn nhất trong k8s 1 pod sẽ đại diện cho 1 hay nhiều 
container được nhóm lại với nhau để chia sẻ tài nguyên hay là mạng và mỗi pods sẽ có 1 IP server
riêng , có thể nói pods là 1 môi trường chia sẻ hoặc là máy chủ ứng dụng 

### Vào server k8s-master-1

1. tiến hành setup file để chạy pod

``` bash
mkdir projects
cd projects

---------------------------------------

# tạo namespace 
nano ns.yaml

# nội dung bên trong ns.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: frontend

----------------------------------------

# tạo resource cho namespace
nano resourcequota.yaml

# nội dung trong file resourcequota.yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: mem-cpu-quota
  namespace: frontend
spec:
  hard:
    requests.cpu: "2"
    requests.memory: 4Gi

----------------------------------------
# Tạo pod 
nano pod.yaml

# nội dung bên trong file pod.yml
apiVersion: v1
kind: Pod
metadata:
  name: frontend
  namespace: frontend
spec:
  containers:
  - name: frontend
    image: vuduyduc/frontend
    ports:
    - containerPort: 80
```

2. tiến hành chạy các file đã setup

``` bash
kubectl apply -f ns.yaml
kubectl apply -f pod.yaml
kubectl apply -f resourcequota.yaml
kubectl get pod -n frontend # get các pod trong cùng 1 namespace
kubectl exec -it frontend -n frontend -- /bin/bash # dùng để truy cập vào môi trường của namespace đó
kubectl delete -f pod.yaml # dùng để xoá pods này đi 
```

# Deployment với Kubernetes

* Deployment là 1 đối tượng quản lý pods quản lý về mãng ứng dụng

* Scale ứng dụng : tăng số lượng pods để đảm bảo tính hoạt động ổn định

* Tự động khôi phục lỗi : khi một pods bị lỗi sẽ tự tạo lại một pods mới để luôn đảm bảo đủ số lượng
pods

### Vào ranger của devopsk8s trên web đã tạo ở bài trước

1. trên thanh header có Only User Namespaces -> chon vào namespaces Frontend đã triển khai bài trước

2. ở Thanh Cluster -> chọn workloads -> trên thanh headers thấy chỗ mũi tên đi lên (import yaml)
nhấn vào sau đó sẽ thấy Default Namespaces -> chọn frontend -> cancel vì chưa cần thiết

3. bên cạnh nút (import yaml) sẽ thấy nút >_ thì nhấn vào sẽ xuất hiện command line ở dưới giúp chúng
ta đỡ phải truy cập vào server

- kubectl get no

4. bên cạnh nút >_ sẽ có nút (Download KubeConfig) , Coppy , tìm kiếm các tài nguyên

5. Trong workloads sẽ có những phần triển khai các Deployment và Pods

6. Chọn vào Pods -> Create

- Namespaces : frontend
		
- Name : frontend
		
- Container Name : frontend

- Container image : vuduyduc/frontend
		
- Ở phần Networking -> chọn Add Port or Service

- Name : đặt là tcp

- Private Container Port : 80
			
- Create

7. Chúng ta sẽ tạo được một pods và biết được pods đó được tạo trên server nào

8. bên cạnh Age (phần thời gian đang chạy) có nút 3 chấm

- Excute Shell (truy cập vào môi trường của container)
		
- View Log (xem logs của pod đó)
		
- Edit Config (chỉnh sửa config của pods)
		
- Edit YAML (File yaml của pods)
		
- Clone
		
- Download YAML
		
- Delete (ở đây chúng ta sẽ xoá ngay lập tức cụm này)

9. Trong workloads -> chọn Deployments -> Chọn create

- Namespaces : frontend
		
- Name : frontend-deployment
		
- Replicas : đặt lên 3 (có thể đăt bao nhiêu tuỳ theo dự án)
		
- Container Name : frontend
		
- Container image : vuduyduc/frontend
		
* Ở phần Networking -> chọn Add Port or Service
		
- Name : đặt là tcp

- Private Container Port : 80

- Create

10. kết quả thực hiện

* Sau đó qua lại phần Pods có thể nhìn thấy 3 Pods đã được tạo ra (3 pods này cấu hình 
hệt nhau) - và từng Pods đã được triển khai trên từng server như nhau , ngay cả khi có
tự xoá pods hoặc pods đó có bị sập thì Schedule vẫn có thể tự tạo lại cái Pods đó 
		
* Vào lại phần Deployment vào phần Health -> sẽ thấy xuất hiện Scale thêm bằng cách 
nhấn dấu + hoặc giảm bằng dấu trừ
		
* Sau đó quay trở lại pods thì sẽ thấy một pods mới được tạo ra 

### Deploy bằng file yaml

1. Tiến hành Download YAML trong Deployment

``` bash
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    workload.user.cattle.io/workloadselector: apps.deployment-frontend-frontend-deployment
  name: frontend-deployment
  namespace: frontend
spec:
  replicas: 2 // số lượng pods
  revisionHistoryLimit: 11 // Lưu lịch sử 
  selector:
    matchLabels:
      workload.user.cattle.io/workloadselector: apps.deployment-frontend-frontend-deployment
  template:
    metadata:
      labels:
	    workload.user.cattle.io/workloadselector: apps.deployment-frontend-frontend-deployment
	  namespace: frontend
    spec:
	  containers:
	    - image: vuduyduc/frontend
		  imagePullPolicy: Always
		  name: frontend
		  ports:
		    - containerPort: 80
		      name: tcp
		      protocol: TCP
```

2. Bước tiếp theo copy file YAML vừa được edit xong

3. vào Deployment xoá frontend-deployment cũ 

4. chọn Import YAML dán phần đã edit vào file YAML nhớ chọn Default Namespace của dự án -> sau đó import 

5. Sau khi khởi tạo thành công sang Pods sẽ thấy 2 Pods được tạo ra

# Các commands hay dùng Deployment

### vào trong server k8s-master-1

``` bash
cd /projects/frontend
kubectl get deployments -n frontend # trong đó frontend là namespaces, sẽ xuất thiện thông tin NAME (ví dụ frontend-deployment)
kubectl get rs -n frontend
kubectl edit deployment/frontend-deployment
kubectl rollout status deployment/frontend-deployment -n frontend
kubectl scale deployment/frontend-deployment --replicas=4 -n frontend # (trong đó replicas tăng số lương pods) Sau đó vào trong Deployment ở Workloads ở web Rancher để xem số lượng pods đã được tạo ra  
```

``` bash
kubectl scale deployment <ten-deployment> --replicas=<so-replicas> # Cập nhật trực tiếp số lượng replicas
kubectl describe deployment -n <namespace> # Xem chi tiết cụ thể về một Deployment
kubectl get deployment <ten-deployment> -o yaml # Xem cấu hình YAML của một Deployment
kubectl set image deployment/<ten-deployment> <ten-container>=<ten-image>:<tag-moi> # Cập nhật Deployment bằng cách thay đổi hình ảnh container
kubectl rollout undo deployment <ten-deployment> # Rollback Deployment về phiên bản trước
kubectl rollout history deployment <ten-deployment> # Kiểm tra lịch sử các phiên bản của Deployment
kubectl get pods -l app=<ten-deployment> -n <namespace> # Liệt kê các Pod được tạo bởi một Deployment cụ thể
kubectl set env deployment/<ten-deployment> <key>=<value> # Cập nhật biến môi trường cho các container trong Deployment
```

# NodePort K8S Cloud GKE

``` bash
mkdir devops
cd devops
nano frontend.yml
```

``` yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend-deployment
  namespace: frontend
spec:
  replicas: 1
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
          image: vuduyduc/frontend
          ports:
            - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: frontend-service
  namespace: frontend
spec:
  type: NodePort
  selector:
    app: frontend
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
      nodePort: 32080
```

``` bash
# tạo namespace cho frontend
kubectl create ns frontend

# áp dụng toàn bộ cấu hình cho file Yaml
kubectl apply -f frontend.yaml

# lấy toàn bộ thông tin cấu hình 
kubectl get all -n frontend

kubectl get no -o wide
```

1. Vào thanh 3 sọc -> Hover vào VPC Network -> Chọn phần Firewall -> tiến hành Create FIREWALL RULE
	
- kéo xuống Name và điền vào ô Input đó là (allow-port:32080) 

- kéo xuống Targets -> chọn vào All instances in the network

- kéo xuống source IPv4 rangers -> điền vào 0.0.0.0/0
	
- kéo xuống Specified protocols and ports
		
- Chọn TCP và để port là 32080

- CREATE
	
2. vào lại Command Line của Cloud 

- curl đến IP của 1 server EXTERNAL-IP:32080 (ví dụ 34.86.21.171:32080)
	
- mở tag google mới dán 34.86.21.171:32080 sẽ thấy giao diện của trang frontend

# Triển khai Ingress on Cloud GCP

1. ssh vào trong server GCP

``` bash
kubectl get all -n frontend 
kubectl delete -f frontend.yaml

# tiến hành cài Helm trên Cloud
wget https://get.helm.sh/helm-v3.16.2-linux-amd64.tar.gz
tar xvf helm-v3.16.2-linux-amd64.tar.gz
sudo mv linux-amd64/helm /usr/bin/
helm version

# Ingress Controller
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm pull ingress-nginx/ingress-nginx
tar -xzf ingress-nginx-4.11.3.tgz
kubectl create ns ingress-nginx
helm -n ingress-nginx install ingress-nginx -f ingress-nginx/values.yaml ingress-nginx

kubectl create ns ecommerce

# tiến hành tạo file yaml để sử dụng service ingress
nano frontend-service-dp-sv-ig.yaml
```

``` yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: ecommerce-backend
  name: ecommerce-backend-deployment
  namespace: ecommerce
spec:
  replicas: 2
  revisionHistoryLimit: 11
  selector:
    matchLabels:
      app: ecommerce-backend
  strategy:
    rollingUpdate:
      maxSurge: 25%
      maxUnavailable: 25%
    type: RollingUpdate
  template:
    metadata:
      labels:
        app: ecommerce-backend
    spec:
      containers:
        - image: vuduyduc/ecommerce-backend:v1
          imagePullPolicy: Always
          name: backend
          ports:
            - containerPort: 8080
              name: http
              protocol: TCP
---
apiVersion: v1
kind: Service
metadata:
  name: ecommerce-backend-service
  namespace: ecommerce
spec:
  ports:
    - name: http
      port: 8080
      protocol: TCP
      targetPort: 8080
  selector:
    app: ecommerce-backend
  type: ClusterIP
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ecommerce-backend-ingress
  namespace: ecommerce
spec:
  ingressClassName: nginx
  rules:
    - host: ecommerce-backend-onpre.devopsedu.vn
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: ecommerce-backend-service
                port:
                  number: 8080
```

3. tiến hành triển khai

``` bash 
kubectl apply -f frontend-dp-sv-ig.yaml

kubectl get all -n ecommerce

# địa chỉ Address và domain tự tạo tiến hành copy Address bỏ vào hosts System32
kubectl get ingress -n ecommerce
```

# configMap trong k8s

- ConfigMap là một đối tượng (resource) trong Kubernetes dùng để lưu trữ dữ liệu cấu hình dạng key–value.

- Nó giúp tách cấu hình ra khỏi ứng dụng → để bạn không phải build lại Docker image mỗi lần muốn thay đổi config.

``` yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: my-config
  namespace: default
data:
  PORT: "3000"
  DATABASE_HOST: "db-service"
```

1. Không cần rebuild image khi đổi config.

2. Quản lý cấu hình tập trung.

3. Có thể gắn config vào container dưới dạng:

- Biến môi trường (env vars).

- File (mount vào thư mục, giống như file application.properties cho Spring Boot).

### ConfigMap = nơi lưu cấu hình key–value trong Kubernetes, để Pod/Container dùng mà không cần sửa code hoặc rebuild image.

# Triển khai dự án fullstack

### Chuẩn bị 1 server để triển khai dự án và đóng gói các images

* cài đặt Docker

``` bash
nano install-docker.sh
```

``` bash
# nội dung bên trong 
!#/bin/bash

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

* Dockerfile Frontend Vue

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

* build docker image frontend

``` bash
docker build -t ecommerce-frontend:v1 .

# tiến hành push lên repo dockerhub
docker login

# Username: điền Username trên dockerhub
# Passowrd: điền password trên dockerhub

# Rename cho docker images trùng với trên repo
# Nhớ tạo repo đó trên dockerhub trước khi push lên dockerhub

docker tag ecommerce-frontend:v1 vuduyduc/ecommerce-frontend:v1

# Push lên dockerhub
docker push vuduyduc/ecommerce-frontend:v1
```

* Dockerfile Backend Java Springboot

``` Dockerfile
FROM maven:3.8-openjdk-17 AS build

WORKDIR /app
COPY . .
RUN mvn clean package -DskipTests

# Runtime stage
FROM openjdk:17-jdk

WORKDIR /run
COPY --from=build /app/target/VegetFood-1.0.jar /run/VegetFood-1.0.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "/run/VegetFood-1.0.jar", "--spring.config.location=/run/src/main/resources/application.properties"]
```

* build docker image backend

``` bash
docker build -t ecommerce-backend:v1 .

# tiến hành push lên repo dockerhub
docker login

# Username: điền Username trên dockerhub
# Passowrd: điền password trên dockerhub

# Rename cho docker images trùng với trên repo
# Nhớ tạo repo đó trên dockerhub trước khi push lên dockerhub

docker tag ecommerce-backend:v1 vuduyduc/ecommerce-backend:v1

# Push lên dockerhub
docker push vuduyduc/ecommerce-backend:v1
```

### Triển khai fullstack trên k8s

1. Tạo namespace

``` bash
nano ns-fullstack.yaml
```

``` yaml
apiVersion: v1
kind: Namespace
metadata:
  name: fullstack
```

* tạo resouce cho namespace đó

``` bash
nano resourcequota-fullstack.yaml
```

``` yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: mem-cpu-quota
  namespace: fullstack
spec:
  hard:
    requests.cpu: "2"
    requests.memory: 4Gi
```

* Triển khai configMap cho backend

``` bash
nano backend-config.yaml
```

``` yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: backend-config
  namespace: fullstack
data:
  application.properties: |
    spring.datasource.url=jdbc:mysql://<IP-SERVER>:3306/paymentdb
    spring.datasource.username=payment
    spring.datasource.password=payment
    spring.datasource.driverClassName=com.mysql.cj.jdbc.Driver
```

2. Triển khai fullstack trong 1 file

``` bash
nano fullstack-project.yml
```

``` yaml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: ecommerce-backend
  name: ecommerce-backend-deployment
  namespace: fullstack
spec:
  replicas: 2
  revisionHistoryLimit: 11
  selector:
    matchLabels:
      app: ecommerce-backend
  strategy:
    rollingUpdate:
      maxSurge: 25%
      maxUnavailable: 25%
    type: RollingUpdate
  template:
    metadata:
      labels:
        app: ecommerce-backend
    spec:
      containers:
        - image: vuduyduc/ecommerce-backend:v1
          imagePullPolicy: Always
          name: ecommerce-backend
          ports:
            - containerPort: 8080
              name: tcp
              protocol: TCP
          volumeMounts:
            - name: config-volume
              mountPath: /run/src/main/resources/application.properties   
              subPath: application.properties
      volumes:
      - name: config-volume
        configMap:
          name: backend-config          
---
apiVersion: v1
kind: Service
metadata:
  name: ecommerce-backend-service
  namespace: fullstack
spec:
  ports:
    - name: tcp
      port: 8080
      protocol: TCP
      targetPort: 8080
  selector:
    app: ecommerce-backend
  type: ClusterIP
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: ecommerce-frontend
  name: ecommerce-frontend-deployment
  namespace: fullstack
spec:
  replicas: 2
  revisionHistoryLimit: 11
  selector:
    matchLabels:
      app: ecommerce-frontend
  strategy:
    rollingUpdate:
      maxSurge: 25%
      maxUnavailable: 25%
    type: RollingUpdate
  template:
    metadata:
      labels:
        app: ecommerce-frontend
    spec:
      containers:
        - image: vuduyduc/ecommerce-frontend:v1
          imagePullPolicy: Always
          name: ecommerce-frontend
          ports:
            - containerPort: 80
              name: tcp
              protocol: TCP
---
apiVersion: v1
kind: Service
metadata:
  name: ecommerce-frontend-service
  namespace: fullstack
spec:
  ports:
    - name: tcp
      port: 80
      protocol: TCP
      targetPort: 80
  selector:
    app: ecommerce-frontend
  type: ClusterIP
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ecommerce-domain-ingress
  namespace: fullstack
spec:
  ingressClassName: nginx
  rules:
    - host: ecommerce-domain.devops.vn
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: ecommerce-frontend-service
                port:
                  number: 80
          - path: /api
            pathType: Prefix
            backend:
              service:
                name: ecommerce-backend-service
                port:
                  number: 8080
```

3. Tiến hành triển khai với các câu lệnh

``` bash
kubectl apply -f ns-fullstack.yaml
kubectl apply -f backend-config.yaml
kubectl apply -f resourcequota-fullstack.yaml
kubectl apply -f fullstack-project.yml
kubectl get all -n fullstack
```