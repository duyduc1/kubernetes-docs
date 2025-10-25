# System monitoring with Log

### Cài đặt Loki & Promtail

``` bash
sudo mkdir -p /etc/loki /var/lib/loki
sudo mkdir -p /etc/promtail /var/lib/promtail
sudo mkdir -p /var/lib/loki/chunks /var/lib/loki/index /var/lib/loki/index_cache /var/lib/loki/compactor
```

### Tải Loki & Promtail binaries

``` bash
cd /usr/local/bin

# Tải Loki
sudo wget https://github.com/grafana/loki/releases/download/v2.9.4/loki-linux-amd64.zip
sudo apt install unzip -y
sudo unzip loki-linux-amd64.zip
sudo chmod +x loki-linux-amd64
sudo mv loki-linux-amd64 /usr/local/bin/loki

# Tải Promtail
sudo wget https://github.com/grafana/loki/releases/download/v2.9.4/promtail-linux-amd64.zip
sudo unzip promtail-linux-amd64.zip
sudo chmod +x promtail-linux-amd64
sudo mv promtail-linux-amd64 /usr/local/bin/promtail
```

### Cấu hình Loki

``` bash
sudo nano /etc/loki/config.yaml
```

``` yaml
auth_enabled: false

server:
  http_listen_port: 3100

ingester:
  lifecycler:
    address: 127.0.0.1
    ring:
      kvstore:
        store: inmemory
      replication_factor: 1
  chunk_idle_period: 5m
  chunk_target_size: 1048576
  chunk_retain_period: 30s

schema_config:
  configs:
    - from: 2024-01-01
      store: boltdb-shipper
      object_store: filesystem
      schema: v11
      index:
        prefix: index_
        period: 24h

storage_config:
  boltdb_shipper:
    active_index_directory: /var/lib/loki/index
    cache_location: /var/lib/loki/index_cache
    shared_store: filesystem
  filesystem:
    directory: /var/lib/loki/chunks

limits_config:
  retention_period: 168h

compactor:
  working_directory: /var/lib/loki/compactor
  shared_store: filesystem
```

### Cấu hình Promtail

``` bash
sudo nano /etc/promtail/config.yaml
```

``` yaml
server:
  http_listen_port: 9080
  grpc_listen_port: 0

positions:
  filename: /var/lib/promtail/positions.yaml

clients:
  - url: http://localhost:3100/loki/api/v1/push

scrape_configs:
  - job_name: docker
    static_configs:
      - targets:
          - localhost
        labels:
          job: docker
          __path__: /var/lib/docker/containers/*/*.log
  - job_name: backend-logs
    static_configs:
      - targets:
          - localhost
        labels:
          job: backend
          __path__: /var/log/backend/*.log
```

### Tạo service systemd cho Loki

``` bash
sudo tee /etc/systemd/system/loki.service > /dev/null <<'EOF'
[Unit]
Description=Loki Log Aggregator
After=network.target

[Service]
User=root
ExecStart=/usr/local/bin/loki -config.file=/etc/loki/config.yaml
Restart=always
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF
```

### Tạo service systemd cho Promtail

``` bash
sudo tee /etc/systemd/system/promtail.service > /dev/null <<'EOF'
[Unit]
Description=Promtail Log Collector
After=network.target docker.service
Requires=docker.service

[Service]
User=root
ExecStart=/usr/local/bin/promtail -config.file=/etc/promtail/config.yaml
Restart=always
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF
```

### Khởi động dịch vụ

``` bash
sudo systemctl daemon-reload
sudo systemctl enable loki promtail
sudo systemctl start loki promtail

sudo systemctl status loki
sudo systemctl status promtail

### Kiểm tra cổng
curl http://localhost:3100/ready
``` 

### Add Log vào dashboard

1. Đăng nhập Grafana (admin / <mật khẩu>)

2. Connections → Data sources → Add data source

3. Chọn Loki

4. Điền URL: (server triển khai Loki và Promtail ví dụ http://10.1.0.23:3100)

5. Bấm Save & Test

### Hiển thị log trên Grafana

1. Trong Grafana, vào menu bên trái → Explore

2. Ở góc trên chọn Data source: Loki

3. Bấm vào nút Label browser (ở ngay trên phần truy vấn)

4. Chọn 1 trong 

``` nginx
container_name
job
host
filename
```

5. chọn Show logs 

6. Nhấn Add > chọn Add to dashboard

7. chọn Open dashboard nếu chưa có sẵn dashboard || nếu chưa có thì nhấn Exist dashboard rồi chọn dashboard đã tạo trước đó

8. Sau đó save dashboard