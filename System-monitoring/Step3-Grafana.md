# Alertmanager và Grafana

## 1. Cài đặt Grafana và liên kết Datasource

- Cài đặt Grafana: https://grafana.com/docs/grafana/latest/setup-grafana/installation/debian/

``` bash
sudo apt-get install -y apt-transport-https software-properties-common wget
sudo mkdir -p /etc/apt/keyrings/
wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor | sudo tee /etc/apt/keyrings/grafana.gpg > /dev/null
echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list
sudo apt-get update
sudo apt-get install -y grafana
grafana-server -v
```

- Chạy dịch vụ:

``` bash
sudo systemctl start grafana-server
sudo systemctl enable grafana-server
systemctl status grafana-server
```

- Grafana hoạt động ở port 3000, các bạn truy cập http://:3000 với tài khoản mật khẩu <br> admin/admin

## 2. Steup

1. Sau đó vào Connections/Add new connections và thêm Prometheus

2. Điền thông tin địa chỉ Prometheus mà các bạn kết nối: http://<ip-server>:9090 

- Sau đó ấn Save & Test để kiểm tra:

3. Bây giờ các bạn có thể vào Explore view để xem các dữ liệu từ Prometheus đã được nhận <br> về Grafana hoặc vào building a dashboard để tạo biểu đồ.

4. vào Dashboard chọn import a dasboard 

5. Một Dashboard có sẵn cho Node Exporter, các bạn nhập ID 1860 và ấn Load

6. Chọn Datasource về Prometheus:

7. Import