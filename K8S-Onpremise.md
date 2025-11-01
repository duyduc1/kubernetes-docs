# K8S là gì 

- Kubernetes là một công cụ giúp thuận lợi trong việc cấu hình tự động hóa triển khai các ứng dụng.

# Khi nào nên sử dụng k8s

1. 	Điều kiện áp dụng giải pháp

- Hiệu quả , minh bạch , khả năng vận hành , tối ưu chi phí

2. Dự án phù hợp áp dụng k8s

- Dự án lớn , dự án chạy đường dài 

- Dự án có nhu cầu cao về mở rộng 

- Dự án cần triển khai đa môi trường 

- Dự án theo mô hình Microservices

- Dự án cần khả năng tự phục hồi (Self-Healing)

# Triển khai Cluster 

## Trong 1 cụm k8s bao gồm: 1 cụm cluster bao gồm các Node và 1 cụm Control Plane

### 1. Node

- Có thể có nhiều pod 

- mỗi pod lưu trữ các containter có thể có nhiều container , pod là đơn vị nhỏ nhất trong cum k8s 

- kubelet là thành phần nhận yêu cầu từ Kube-api-server để thực thi các pod trên node

- kube-proxy là thành phần network chạy trên mỗi node cho phép các pod giao tiếp với nhau và giao tiếp ra bên ngoài

### 2. Control Plane 

- cloud-control-manager máy chủ quản lý

- kube-api-server : là một API quy chuẩn chung để giao tiếp ở ngoài vào trong cụm
ví dụ cloud control manager có yêu cầu lấy thông tin pod của node thì kube-api-server sẽ lấy thông tin tương ứng pod của node cần đó

- etcd : là một csdl phân tán dùng để lưu trữ mọi cấu hình của k8s và các trạng tháng của pod , node , các tài nguyên 

- scheduler : trách nhiệm phân phối pod tới các node trong cluster và nó sẽ xem các yếu tố như tài nguyên, ram , CPU , các chính sách , yêu cầu cụ thể khác 

- Controller Manager : Là thành phần quản lý các controller và tiến trình để chịu trách nhiệm giám sát các trạng thái của cluster và thực hiện các hành động sửa chửa tự động nếu cần
- (Ví dụ khi dự án của bạn đang chạy trên node 1 mà bị lỗi thì controller manager sẽ tự động giám sát và tạo ra một pod mới để đảm bảo dự án của bạn chạy ổn định)

# K8S Chia thành 2 môi trường chính đó là On-premise và Cloud

# Triển khai trên môi trường On-premise

- Điều kiện tối thiểu phải có ít nhất 3 server để triển khai trong đó 1 máy làm Master mặc định là không được triển khai dự án lên đó và 2 node còn lại làm worker có thể triển khai dự án

- Triển khai ít nhât 3 máy chủ ubuntu 1 máy làm Master , 2 máy còn lại làm worker

## Step 1: 

- vào nano /etc/hosts sau đó add 3 IP server của 3 cụm node vào và sau đó đặt tên k8s-master-1 , k8s-master-2 , k8s-master-3 cho từng ip đó và làm như thế với 2 node còn lại

- vào nano /etc/hostname của 3 server thành k8s-master-1 , k8s-master-2 , k8s-master-3

## Step 2:

- k8s-master-1 && k8s-master-2 && k8s-master-3 

``` bash
sudo apt update -y && sudo apt upgrade -y
adduser devops-k8s 
usermod -aG sudo devops-k8s
su devops-k8s
sudo swapoff -a 
cat /etc/fstab
sudo sed -i '/swap.img/s/^/#/' /etc/fstab

sudo tee /etc/modules-load.d/containerd.conf <<EOF
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

sudo tee /etc/sysctl.d/kubernetes.conf <<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

sudo sysctl --system
sudo apt install -y curl gnupg2 software-properties-common apt-transport-https ca-certificates

sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmour -o /etc/apt/trusted.gpg.d/docker.gpg

sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

sudo apt update -y
sudo apt install -y containerd.io

containerd config default | sudo tee /etc/containerd/config.toml >/dev/null 2>&1
sudo sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml

sudo systemctl restart containerd
sudo systemctl enable containerd
sudo systemctl status containerd
sudo mkdir -p /etc/apt/keyrings

curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt update -y
sudo apt install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
```

## Step 3

- Chọn k8s-master-1 làm cụm master 

``` bash
sudo kubeadm init  
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# ( ta sẽ thấy thông tin câu lệnh kubeadm join ip của cụm k8s-master-1:6443 --token h2kmsp. và sau đó - nhớ copy khúc câu lệnh đó bỏ qua 2 cụm worker k8s-master-1 và k8s-master-2)

kubectl get nodes
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/calico.yaml
kubectl get nodes
kubectl label node k8s-master-2 node-role.kubernetes.io/worker=
kubectl label node k8s-master-3 node-role.kubernetes.io/worker=
```

- Chọn k8s-master-2 && k8s-master-3 làm cụm worker

### copy câu lệnh sudo kubeadm join ip của k8s-master-1:6443 --token h2kmsp.sau đó và nhớ paste khúc câu lệnh đó bỏ qua 2 cụm worker k8s-master-1 và k8s-master-2

# File yaml Cấu hình trong k8s

### Ưu điểm file yaml

- Cú pháp đơn giản

- Định dạng phong phú 

- Cấu trúc rõ ràng 

- Cộng đồng lớn
	
### Cấu trúc file yaml

- key là tên thuộc tính

- value là giá trị tương ứng

### Ví dụ trong Kubernetes: name: my-app

key: value
map:
    key1: value1
    key2: value2
list :
  - element1
  - element2
    # This is a comment
listOfMaps:
  - key1: value1a
    key2: value1b
  - key1: value2a
    key2: value2b

// Example 
containers:
  - name: app
        image: nginx
  - name: sidecar
	    image: busybox
env:
  - name: DB_HOST
        value: localhost
  - name: DB_PORT
	    value: "5432"

### Thành phần chính cấu trúc yaml k8s
	
## 1. apiVersion: v1 -> Dùng cho: Tài nguyên cơ bản (core resources)

- Ví dụ: Pod, Service, ConfigMap, Secret, Namespace, PersistentVolume, PersistentVolumeClaim,..., ReplicaSet
	
### apiVersion: apps/v1  -> Dùng cho: Quản lý workload (ứng dụng chạy trên cluster)
- Ví dụ: Deployment, StatefulSet, DaemonSet, ReplicaSet
	
### apiVersion: batch/v1 -> Dùng cho: Tác vụ theo lô hoặc định kỳ
- Ví dụ: Job, CronJob
	
### apiVersion: networking.k8s.io/v1 -> Dùng cho: Mạng và ingress
- Ví dụ: Ingress, NetworkPolicy 
	
### apiVersion: policy/v1 -> Dùng cho: Chính sách bảo mật
- Ví dụ: PodDisruptionBudget (giới hạn số Pod bị stop khi cập nhật)
	
### apiVersion: rbac.authorization.k8s.io/v1 -> Dùng cho: Phân quyền truy cập (RBAC)
- Ví dụ: Role, ClusterRole, RoleBinding, ClusterRoleBinding
	
### apiVersion: autoscaling/v1 -> Dùng cho: Tự động scaling (tự tăng/giảm tài nguyên)
- Ví dụ: HorizontalPodAutoscaler (HPA)

### apiVersion: storage.k8s.io/v1 -> Dùng cho: Cấu hình lưu trữ
- Ví dụ: StorageClass, CSIDriver, VolumeAttachment

## 2. kind: Pod

- Ý nghĩa: Là đơn vị nhỏ nhất trong Kubernetes, chứa container hoặc nhiều container chạy chung network.
- Khi dùng: Khi bạn muốn chạy một container (hoặc vài cái gắn liền) đơn lẻ.
- Lưu ý: Không nên deploy trực tiếp Pod trong production — dùng Deployment sẽ tốt hơn.

### kind: Deployment
- Ý nghĩa: Quản lý việc tạo và cập nhật nhiều bản sao (Replica) của một Pod.
- Khi dùng: Khi muốn deploy ứng dụng ổn định, có khả năng tự động cập nhật, rollback.
- Ví dụ: Web app, backend services...

### kind: StatefulSet
- Ý nghĩa: Tương tự Deployment nhưng dành cho ứng dụng có trạng thái, yêu cầu lưu trữ ổn định và tên định danh cố định.
- Khi dùng: Database như MySQL, PostgreSQL, Kafka, Zookeeper...
- Lưu ý: Các Pod sẽ được tạo theo thứ tự, và có volume riêng gắn liền với tên Pod.

### kind: DaemonSet
- Ý nghĩa: Đảm bảo mỗi node đều có 1 bản chạy của Pod.
- Khi dùng: Chạy các agent như log collector (Fluentd, Filebeat), monitoring (Prometheus Node Exporter).
- Đặc biệt: Tự động thêm Pod khi có node mới được thêm vào cluster.

### kind: Service
- Ý nghĩa: Cung cấp endpoint ổn định (DNS/IP ảo) để các Pod khác có thể truy cập.
- Khi dùng: Khi muốn expose Pod ra bên ngoài hoặc kết nối giữa các Pod nội bộ.
- Loại phổ biến: ClusterIP, NodePort, LoadBalancer.

### kind: Ingress
- Ý nghĩa: Cung cấp routing HTTP(S) đến Service theo domain/path.
- Khi dùng: Khi bạn cần truy cập ứng dụng từ bên ngoài qua địa chỉ như myapp.com.
- Yêu cầu: Cần cài Ingress Controller (nghĩ như reverse proxy).

### kind: ConfigMap
- Ý nghĩa: Lưu trữ cấu hình dạng key-value không nhạy cảm.
- Khi dùng: Truyền file config, biến môi trường vào Pod.
- Ví dụ: application.properties, flags...

### kind: Secret
- Ý nghĩa: Tương tự ConfigMap nhưng dùng để lưu thông tin nhạy cảm (đã mã hóa base64).
- Khi dùng: Lưu mật khẩu, token, SSH key...
- An toàn hơn ConfigMap: Vì kube-apiserver xử lý đặc biệt.

### kind: PersistentVolume (PV)
- Ý nghĩa: Tài nguyên lưu trữ được cung cấp bởi admin (file system, cloud disk…).
- Khi dùng: Tạo volume lưu trữ cố định cho Pod.
	
### kind: PersistentVolumeClaim (PVC)
- Ý nghĩa: Lời yêu cầu sử dụng PV của người dùng.
- Khi dùng: Gắn volume vào Pod bằng cách claim (yêu cầu) từ PV có sẵn hoặc tự tạo theo StorageClass

## 3. Metadata, 

## 4. spec

# NameSpace trong K8S

- Trong k8s namespace là một cách tổ chức và phân tách các tài nguyên trong một cụm k8s để quả lý tốt hơn , 
được sử sụng để chia nhỏ tài nguyên của một cụm lớn thành các không gian làm việc logic nhỏ hơn , giúp dễ dàng quản lý và vận hành

### trong k8s-master-1

- tạo namespace

``` bash
kubectl get pod --namespace default
kubectl get ns 

# (sẽ tạo ra namespace/project-1 created)
kubectl create ns project-1

# (sẽ xoá namespace/project-1 deleted)
kubectl delete ns project-1 
mkdir projects
cd projects
mkdir project-1
cd project-1

# tạo ra một namespace
nano ns.yaml

# nội dung trong file ns.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: project-1

# (namespace/project-1 created)
kubectl apply -f ns.yaml
kubectl get ns

# (namespace/project-1 deleted)
kubectl delete -f ns.yaml
```

- tạo resouce cho namespace đó

``` bash
nano resourcequota.yaml

# nội dung trong file resourcequota.yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: mem-cpu-quota
  namespace: project-1
spec:
  hard:
    requests.cpu: "2"
    requests.memory: 4Gi

# tạo resouce cho namespace
kubectl apply -f resourcequota.yaml
```

# Công cụ quản lý Kubernetes 

* K8s management tools ( command app , Desktop app , Website app)

* K9s là 1 công cụ quản lý k8s trên môi trường command line

* Công cụ quản lý k8s bằng Desktop App (lens) quản lý bằng giao diện

* Công cụ quản lý k8s bằng nền tảng web Rancher (được hỗ trợ phân quyền mạnh mẽ)

# Cài đặt Rancher và quản lý K8S

- Rancher là một công cụ giúp triển khai và quản lý giám sát nhiều cum K8S trên các môi trường khác nhau bao gồm cả On-premise và các dịch vụ như AWS , Azure , Google Cloud Plasform 

- Rancher làm được gì
	
1. Quản lý nhiều cụm K8S

2. Phân quyền mạnh mẽ ( based RBAC Kubernets)

3. Hõ trợ giám sát cụm Kubernetes

4. Bảo mật tốt

- Cài đặt Rancher bằng Docker hoặc chạy Rancher lên trực tiếp cụm K8S

``` bash
sudo -i
apt-update
apt install docker && apt install docker-compose
mkdir /data/rancher
cd /data/rancher
nano docker-compose.yml

# nội dung trong file yml
version: '3'
services:
  rancher-server:
    image: rancher/rancher:v2.9.2
    container_name: rancher-server
    restart: unless-stopped
    ports:
	  - "80:80"
	  - "443:443"
	volumes:
	  - /data/rancher/data:/var/lib/rancher
    privileged: true

# build và run
docker-compose up -d --build
docker ps -a
docker logs rancher-server 2>&1 | grep "Bootstrap Password:" # lấy mật khẩu
```

- dán password vừa lấy được vào trong web rancher 

1. chọn Set a specifsc password to use

2. New Password

3. Confirem New Password

4. Tích chọn By checking the box , you accept the End User -> Saving

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
nano pod.yml

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
  replicas: 2
  revisionHistoryLimit: 11 
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

#  Các chiến lược triển khai Deployment k8s

## Có 2 chiến lượng triển khai

### Recreate (tạo mới hoàn toàn các Pods)

- Xoá toàn bộ pods đi và khởi tạo lại toàn bộ pods mới

* Đây là file YAML của Recreate - chiến lượt thứ Recreate

``` yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: frontend-deployment 
  name: frontend-deployment
  namespace: frontend
spec:
  replicas: 4 
  strategy:
    type: Recreate
  revisionHistoryLimit: 11 
  selector:
    matchLabels:
      app: frontend-deployment 
  template:
    metadata:
      labels:
        app: frontend-deployment
      namespace: frontend
    spec:
      containers:
        - image: nginx
          imagePullPolicy: Always
          name: frontend
          ports:
            - containerPort: 80
              name: tcp
              protocol: TCP
```

### Rolling Update (cập nhật dần các Pods) 
		
- ví dụ chúng ta có 2 pods và triển khai version mới chúng ta thiết lập rằng cứ có 1 pods mới lên thì xoá một pods cũ đi vậy chúng ta sẽ có 1 pods version cũ và 1 pods version mới vẫn có thể đảm bảo dự án hoạt động được .

* Đây là file YAML của Rolling Update - chiến lượt thứ Rolling Update

``` yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: frontend-deployment
  name: frontend-deployment
  namespace: frontend
spec:
  replicas: 2
  strategy:
    rollingUpdate:
      maxSurge: 1 #25%
      maxUnavailable: 1 #25%
    type: RollingUpdate
  revisionHistoryLimit: 11
  selector:
    matchLabels:
      app: frontend-deployment
  template:
    metadata:
      labels:
        app: frontend-deployment
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

# Các loại Service trong K8S

1. Service trong K8S là một đối tượng dùng để định nghĩa cách tiếp cận các pods thường là 1 nhóm pods hay chính xác là triển khai các pods qua deployment trong cụm k8s

2. Service Type : có 4 loại 

	- Cluster IP : tạo ra một địa chỉ IP chỉ có thể truy cập được ở trong cụm có thể giao tiếp được với nhau , nếu muốn giao tiếp ra bên ngoài thì cần phải đi qua ingress

	- NodePort : Service này sẽ trực tiếp mở 1 port truy cập từ bên ứng dụng ra bên ngoài , tức là chúng ta có thể truy cập trực tiếp vào pods mà không cần phải đi qua bất cứ cổng nào nữa.

	- LoadBalancer : Dành cho clound Provider , sẽ điều phối lưu lượng tới các service tương ứng 

	- ExternalName : sẽ liên kết với 1 tên miền ở bên ngoài (domain)

3. Cluster IP và LoadBalancer là 2 loại service giúp chuyển khai dự án chuyên nghiệp và thực tế với Cluster IP sẽ được áp dụng trên môi trường On-premise và LoadBalancer sẽ áp dụng cho môi trường cloud

# NodePort

1. Chỉ cho phép sử dụng các port từ 300000 - 32767

2. vào trong devopsk8s

3. Trong phần giao diện của Ranchers -> phần Service Discovery -> nhấn chọn vào service
		
- nhấn chọn Create -> nhấn chọn vào NodePort -> đặt Name là frontend-service && Port Name để là tcp && Listening Port đặt là 80 && Target Port là 80 && Node Port đặt ví dụ 32080
		
- Tiếp theo nhìn kỹ sẽ thấy Selectors -> để key là app && Value là frontend-deployment (coi lại file YAML đã cấu hình trong phần Rolling Update ) -> Create

- Sau khi tạo xong sẽ thấy frontend-service đã được tạo với port là 32080 ở đây chúng ta có thể dùng IP Server của k8s-master-2 cộng với port 32080 để truy cập

- bật tag google mới sau đó điền IP của server k8s-master-1 vào sau đó thêm port 32080 ở phía sau

# ClusterIP -> không thể truy cập trực tiếp từ bên ngoài vào

### khởi tạo với dashboard rancher 
	
1. Trong Service Discovery (của devopsk8s) -> chọn Services -> Chọn Create ->  Chọn ClusterIP -> đặt tên Cho Name (frontend1-service) && PortName đặt là tcp && listerning Port là 80 && TargetPort cũng là 80

2. Xuống task Selectors ở bên cạnh -> key là app && Value là frontend-deployment -> CREATE

3. Sau khi tạo xong ở mục target sẽ có một chỗ để link nhấn vào sẽ ra trang web

# Ingress Kubernetes

* Ingress Kubernetes là một tài nguyên dùng để quản lý cách thức truy cập từ bên ngoài vào các service bên trong cụm K8S giúp định hướng lưu lượng truy cập HTTP và HTTPS tới các service nội bộ

* Mô hình đi từ Client -> đến loadbalancer -> đén ingress -> dựa theo hướng dẫn đến các service chính xác và từ service đến Pod tương ứng

* Ingress nginx && Kong Gateway && HAProxy 3 loại hay sử dụng để triển khai trên ingress trên on-premise 

* Helm là một loại công cụ quản lý các tài nguyên được cài đặt bằng helm

* Loadbalencer làm nhiệm vụ cân bằng tải các traffic của NodePort trong K8S đi ra bên ngoài Client

1. Cài đặt helm

* Server master (k8s-master-1)

``` bash
cd && sudo -i
wget https://get.helm.sh/helm-v3.16.2-linux-amd64.tar.gz  
tar xvf helm-v3.16.2-linux-amd64.tar.gz
sudo mv linux-amd64/helm /usr/bin/
```

* add Chart của Ingress Nginx Controller 

``` bash
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm search repo nginx
helm pull ingress-nginx/ingress-nginx
tar -xzf ingress-nginx-4.11.3.tgz
nano ingress-nginx/values.yaml

# Sửa type: LoadBalancer => type: NodePort // vì đang triển khai trên On-premise nên sử dụng NodePort
# Sửa nodePort http: "" => http: "30080"
# Sửa nodePort https: "" => https: "30443"

cp -rf ingress-nginx /home/devops-k8s
su devops-k8s
kubectl create ns ingress-nginx 
helm -n ingress-nginx install ingress-nginx -f ingress-nginx/values.yaml ingress-nginx
helm version
kubectl get all -n ingress-nginx
```

2. triển khai loadbalancer trên on-premise

* Tạo thêm 1 server mới để triển khai Ingress Nginx - server Loadbalancer (192.168.1.110)

* ssh vào server

``` bash
apt install net-tools -y 
apt install nginx -y 
nano /etc/nginx/sites-available/default

# đổi listern 80 -> sang port khác (ví dụ : 9999)

nano /etc/nginx/conf.d/devops-onpre.greenglobal.com.vn.conf
			
# config nginx làm loadbalancer 
upstream my_servers {
    server 192.168.1.111:30080; 
    server 192.168.1.112:30080; 
    server 192.168.1.113:30080;
}
			
server {
	listen 80;
	server_name devops-onpre.greenglobal.com.vn;
	location / {
		proxy_pass http://my_servers;
		proxy_redirect off;
		proxy_set_header Host $host;
		proxy_set_header X-Real-IP $remote_addr;
		proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
		proxy_set_header X-Forwarded-Proto $scheme;
	}
}

# reload nginx
nginx -s reload 
systemctl restart nginx 
``` 

3. tiến hành deploy

* trên web Rancher-server trong devopsk8s tạo Ingress trên Rancher 

* Chọn Servivce Discovery -> chọn Ingress -> Chọn Import YAML

``` yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: frontend-ingress
  namespace: frontend
spec:
  ingressClassName: nginx
  rules:
    - host: devops-onpre.greenglobal.com.vn
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

* Import

* Muốn biết chính xác tài nguyên Ingress này đã trỏ đúng service chưa thì chọn vào phần này frontend-service nếu nó di chuyển sang Pods và ở đó có các pods thì bạn đã triển khai đúng 

* Vào system32 để add hosts và IP của server Nginx Ingress: ví dụ (192.168.1.110 devops-onpre.greenglobal.com.vn) // nếu chứa có domain

* Truy cập bằng domain devops-onpre.greenglobal.com.vn

# Template yaml Kubernetes 

``` yaml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: frontend
  name: frontend-deployment
  namespace: frontend
spec:
  replicas: 2
  revisionHistoryLimit: 11
  selector:
    matchLabels:
      app: frontend
  strategy:
    rollingUpdate:
      maxSurge: 25%
      maxUnavailable: 25%
    type: RollingUpdate
  template:
    metadata:
      labels:
        app: frontend
    spec:
      containers:
        - image: vuduyduc/frontend
          imagePullPolicy: Always
          name: frontend
          ports:
            - containerPort: 80
              name: http
              protocol: TCP
---
apiVersion: v1
kind: Service
metadata:
  name: frontend-service
  namespace: frontend
spec:
  ports:
    - name: http
      port: 80
      protocol: TCP
      targetPort: 80
  selector:
    app: frontend
  type: ClusterIP
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: frontend-ingress
  namespace: frontend
spec:
  ingressClassName: nginx
  rules:
    - host: frontend-onpre.devopsedu.vn
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

### Nếu triển khai trong rancher của k8s thì chỉ cần import file yaml, không cần phải tạo file trong server k8s
