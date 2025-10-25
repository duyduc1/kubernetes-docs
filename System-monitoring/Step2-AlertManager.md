# Install and Config AlerManager trên máy giám sát

## 1. Install AlertManager

### Intall AlertManager

``` bash
sudo -i
mkdir -p /var/lib/alertmanager
wget https://github.com/prometheus/alertmanager/releases/download/v0.26.0/alertmanager-0.26.0.linux-amd64.tar.gz
tar -xzf alertmanager-0.26.0.linux-amd64.tar.gz
cd alertmanager-0.26.0.linux-amd64
sudo mv alertmanager /usr/local/bin/
alertmanager --version
```

### Tạo rule alert trên Prometheus server (*)

- Các bạn tạo một file alert-rules.yml trong thư mục /etc/prometheus/alert-rules.yml ví dụ một rule cơ bản như sau:

- Nhóm “Linux Alert”, cảnh báo “Instance Down”, điều kiện “up == 0”, trong vòng “1m”

``` bash
groups:
  - name: Linux Alert
    rules:
      - alert: Instance Down
        expr: up == 0
        for: 1m
```

- Với up là metrics để đánh giá một target đang hoạt động, up == 0 tức target đang down

``` bash
### Lệnh kiểm tra syntax
promtool check rules /etc/prometheus/alert-rules.yml
```

- Khai báo service Alertmanager với Prometheus (*):

- Các bạn mở file cấu hình /etc/prometheus/prometheus.yml và sửa phần cấu hình alerting <br> thành địa chỉ của Alertmanager để gửi cảnh báo tới Alertmanager.

- Ở phần rule_files trỏ thêm file alert rules vừa tạo (có thể có nhiều rule cũng sẽ liệt kê ở đây)

``` bash
# Alertmanager configuration
alerting:
  alertmanagers:
    - static_configs:
        - targets:
            - 192.168.24.120:9093 # máy giám sát

# Load rules once and periodically
rule_files:
  - alert-rules.yml
  # - "first_rules.yml"
  # - "second_rules.yml"
```

- Chạy lại prometheus server và quay lại prometheus UI, vào phần Alert sẽ thấy các rule và alert:

``` bash
sudo systemctl restart prometheus.service
```

- Giả sử các bạn down server đi để điều kiện up == 0 là đúng.

- Tại Prometheus, các bạn truy vấn metrics up sẽ được nội dung tương tự khai báo trong <br> phần scrape_config:

- Sang thẻ Target trong Prometheus cũng thấy tình trạng Job đã down (lưu ý ở đây là Job <br> mà chúng ta cấu hình down chứ không phải thuộc Alert)

- Sau 1 phút, Prometheus sẽ chuyển sang cảnh báo đỏ và đồng thời bắn thông tin này cho <br> Alertmanager (nếu có).

### (*) Lưu ý là các công việc này thuộc phạm vi của Prometheus và chưa hề động tới <br> Alertmanager vì chúng ta chưa cấu hình Alertmanager.

## 2. Cấu hình xử lý cảnh báo trên Alertmanager

- (**) Bây giờ sẽ đến phần cấu hình Alertmanager xử lý cảnh báo. Alertmanager có một số kênh liên lạc phổ biến: Telegram, Email, Slack, Webhook,…

- Ở đây mình sẽ minh họa là Gmail.

- Để chuẩn bị cần tạo App password/mật khẩu ứng dụng tại tài khoản google:

``` bash
https://myaccount.google.com/apppasswords
```

### Tạo file cấu hình alert notify đến email. Các bạn tạo file cấu hình Alertmanager tại <br> vị trí /etc/alertmanager/alertmanager.yml

``` bash
sudo mkdir /etc/alertmanager/
sudo vi /etc/alertmanager/alertmanager.yml
```

``` bash
global:
  resolve_timeout: 5m
route:
  group_by: ["alertname"]
  group_wait: 10s
  group_interval: 10s
  repeat_interval: 1h
  receiver: "email"
receivers:
- name: "email"
  email_configs:
  - to: "example@gmail.com"
    from: "example@gmail.com"
    smarthost: "smtp.gmail.com:587"
    auth_identity: "example@gmail.com"
    auth_secret: ""
    auth_username: "example@gmail.com"
```

### Giải thích:

- Group by, group wait, group interval là thời gian xử lý các cảnh báo mới cùng nhóm (ở <br> đây là cùng tên cảnh báo)

- Repeat interval là thời gian lặp lại thông báo khi cảnh báo vẫn tiếp diễn liên tục

- Receivers ở đây mình đặt là email và cấu hình SMTP của gmail (các bạn có thể dùng một <br> tài khoản email của công ty gửi sang một email nào đó hoặc tự gửi chính mình)

- Auth_secret là mã ứng dụng bạn vừa tạo

### Tạo dịch vụ chạy alertmanager dưới nền:

``` bash
sudo tee /etc/systemd/system/alertmanager.service << EOF

[Unit]
Description=Alertmanager
Wants=network-online.target
After=network-online.target

[Service]
User=root
Type=simple
Restart=always
ExecStart=/usr/local/bin/alertmanager
--config.file /etc/alertmanager/alertmanager.yml
--storage.path /var/lib/alertmanager/

[Install]
WantedBy=multi-user.target

EOF
```

- Chạy dịch vụ:

``` bash
sudo systemctl daemon-reload
sudo systemctl start alertmanager
sudo systemctl enable alertmanager
sudo systemctl status alertmanager
```

- Mặc định alertmanager sẽ chạy với port 9093, các bạn có thể Silence cảnh báo hoặc lấy <br> Link cảnh báo từ đây

- Các logs cũng như cảnh báo cũng sẽ hiển thị dưới dạng time series tại Prometheus
