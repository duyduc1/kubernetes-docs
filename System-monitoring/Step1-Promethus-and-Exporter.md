# Install Prometheus 

## 3.1 Cài đặt Prometheus

``` bash
sudo -i
mkdir -p /etc/prometheus/ /var/lib/prometheus/
wget https://github.com/prometheus/prometheus/releases/download/v2.39.0/prometheus-2.39.0.linux-amd64.tar.gz
tar -xzf prometheus-2.39.0.linux-amd64.tar.gz
cd prometheus-2.39.0.linux-amd64
sudo mv prometheus promtool /usr/local/bin/
sudo mv consoles/ console_libraries/ /etc/prometheus
prometheus --version
```

- Tạo dịch vụ cho prometheus chạy nền:

``` bash
sudo groupadd --system prometheus
sudo useradd -s /sbin/nologin --system -g prometheus prometheus
sudo chown -R prometheus:prometheus /etc/prometheus/ /var/lib/prometheus/
sudo chmod -R 775 /etc/prometheus/ /var/lib/prometheus/

sudo tee /etc/systemd/system/prometheus.service << EOF

[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Restart=always
Type=simple
ExecStart=/usr/local/bin/prometheus \
  --config.file=/etc/prometheus/prometheus.yml \
  --storage.tsdb.path=/var/lib/prometheus/ \
  --web.console.templates=/etc/prometheus/consoles \
  --web.console.libraries=/etc/prometheus/console_libraries

[Install]
WantedBy=multi-user.target

EOF
```

- Chạy dịch vụ

``` bash
sudo systemctl daemon-reload
sudo systemctl start prometheus
sudo systemctl enable prometheus
sudo systemctl status prometheus
```

### Prometheus hoạt động ở port 9090, bạn có thể sử dụng:

``` bash
curl localhost:9090/metrics
```

## 3.2. Cài Đặt và Cấu Hình Node Exporter (Trên máy cần giám sát)

- Cài đặt Node Exporter: https://github.com/prometheus/node_exporter/releases

``` bash
wget https://github.com/prometheus/node_exporter/releases/download/v1.7.0/node_exporter-1.7.0.linux-amd64.tar.gz
tar -xzf node_exporter-1.7.0.linux-amd64.tar.gz
cd node_exporter-1.7.0.linux-amd64
sudo mv node_exporter /usr/local/bin/
node_exporter --version
```

- Tạo dịch vụ chạy node_exporter dưới nền:

``` bash
sudo tee /etc/systemd/system/node_exporter.service << EOF
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=root
Type=simple
Restart=always
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target

EOF
```

- Chạy dịch vụ

``` bash
sudo systemctl daemon-reload
sudo systemctl start node_exporter
sudo systemctl enable node_exporter
sudo systemctl status node_exporter
```

- Node Exporter hoạt động ở port 9100, bạn có thể sử dụng:

``` bash
curl localhost:9100/metrics
```

## 3.3. Thêm Node Exporter vào Prometheus (Thêm máy cần giám sát và Prometheus của mấy giám sát)

- Mở file cấu hình Prometheus và thêm thông tin node cần thu thập dữ liệu

``` bash
vi /etc/prometheus/prometheus.yml
```

- Các bạn thêm một job nữa ở cuối file tên là “node-exporter”, được config tới targets <br> là IP của node cần giám sát, port tương ứng của exporter.

``` bash
- job_name: "node-exporter" # Tên job giám sát
  static_configs:
  - targets: [":9100"] # IP của Node Exporter
```

- Sau đó khởi động lại dịch vụ Prometheus

``` bash
systemctl restart prometheus.service
```

- Truy cập Prometheus, vào Status/Targets và đảm bảo các mục tiêu cần giám sát đang “UP”.

- Về căn bản, dữ liệu đã được thu thập về Prometheus và có thể truy vấn trực tiếp. Các <br> dữ liệu này bạn có thể tham khảo trên từng loại Exporter sẽ có giá trị khác nhau, <br> mình sẽ đề cập chi tiết ở những bài sau.
