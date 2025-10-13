# Lộ trình Logging for DevOps

### Tuỳ vào vị trí sẽ có quyền và tác động khác nhau

- Developer

- Operator

- DevOps

## 1. Logging là gì ? Logging để làm gì ?

1. Tìm hiểu về Logging

- Nhu cầu -> Giải pháp -> Công nghệ

2. Tầm quan trọng của Log

- Giám sát và vận hành 

- Debug và phân tích sự cố

- Cải thiện hiệu năng và trải nghiệm

- Bảo mật và audit

- Phân quyền trách nhiệm

## 2. Khi nào cần hệ thống Logging tập trung

### log truyền thống

- tail 

- docker logs

- kubectl logs

### Khi nào cần hệ thống Loggingg tập trung

1. Bài toán cụ thể

- Hệ thống phân tán

- Dự án mô hình microservices

- Cần thu thập log để phân tích

- Muốn truy vết sự cố bài bản

- Tính chất mất log của công cụ

- Compliance & Audit

2. Yêu cầu khách hàng

- Hệ thống chạy 1:1

- Phân tích và giám sát chủ động

- Số lượng Log lớn nhiều định dạng

- Chuẩn hoá schema

3. Lợi ích

- Tìm kiếm nhanh chóng

- Lưu trữ lâu dài

- Phân quyền cụ thể

- Tự động cảnh báo

## 3. Có nhưng loại Log nào trong thực tế

1. Application Logs

- Ghi lại hành vi trạng thái của ứng dụng dự án

2. System logs

- Ghi lại Log hệ điều hành và service nền tảng

3. Infrastructure / Platform logs

- Theo dõi trạng thái hạ tầng nhưng tầng platform

4. Access logs

- Theo dõi request đến hệ thống

5. Security / Audit logs

- Ghi lai hoạt động đến bảo mật, quyền truy cập

6. Event logs

- Ghi nhận sự kiện nghiệp vụ hoặc sự kiện hệ thống ở mức high-level

7. Trace logs

- Theo dõi toàn bộ đường đi của 1 request qua nhiều services

## 4. Tưu duy thiết kế hệ thống Logging

1. Structed Logging 

- Chuyển các log dạng thô ra format dạng Json

2. Context / Correlation ID

- Log phải gắn với Context cụ thể, nếu không gắn vào trace_id thì sẽ khong biết <br> request nào gây ra lỗi, Debug tìm theo trace_id sẽ dễ dàng biết request nào lỗi và <br> dể khoanh vùng 

3. Log level

- Sử dụng log level hợp lý chỉ bật khi cần điều tra sự cố 

- Log info coi hoạt động bình thường

- level warn có vấn đề nhưng chưa xảy ra nghiêm trọng

4. Các Log level

- DEBUG

- INFO

- WARN

- ERROR

- CRITICAL/FATAL

5. Không lưu log dữ liệu nhạy cảm

- Password

- Token

- Secret

- PII

- File upload

6. Log phải dễ truy vấn và khả năng lưu trữ lâu dài

- Lưu trữ log ngắn hạn (dev/test)

- Lưu trữ log dài hạn (prod)

## 5. Các thành phần trong hệ thống Logging tập trung

1. Thành phần Log Producer (Nguồn sinh log)

- là nơi log được sinh ra: Ứng dụng, container, hệ điều hành, cloud

2. Log Collector / Agent

- Thu thập log tại máy chủ/ứng dụng, gửi về hệ thống tập trung

3. Log Transport / Forwarder

- Truyền tải log từ collector đến storage

4. Log Processor

- Chuyển đổi log về dạng có cấu trúc, enrich thêm metadata (như dạng json)

5. Log Storage / Index

- Lư trữ log lâu dài, có khả năng truy vấn, ví dụ như Elasticsearch, Loki

6. Log Query & Visualization (Truy vấn & Hiển thị)

- Giúp dễ dàng tìm kiếm và phân tích log

7. Alerting & Intergration 

- Chủ động thông báo khi có bất thường 

### Không nên nhồi tất cả log vào 1 nơi mà không có chiến lược

### Luôn enrich log bằng service_name, environment, đễ dễ filter

### Chọn storage phù hợp

### Elasticsearch mạnh về query nhưng tốn tài nguyên

### Loki rẻ hơn nhưng không phù hợp khi cần truy vấn phức tạp

## 6. Lựa chọn công nghệ logging như thế nào ?

### Logging stack nên dùng

- Loki grafana

- ELK stack (Elasticsearch, Logstash, Kibana) - Buffer (Redis, kafka)

- EFK stack (Elasticsearch, Fluentbit/FluentD, Kibana)

- VEK stack (Vector, Elasticsearch, Kibana)

## 7. Tìm hiểu các logging stack(ELK, EFK, Grafana Loki)

1. Grafana - Loki

### Workflow

- Logs > Promtail > Grafana Loki > Grafana

- Promtail là 1 agent được cài đặt trên server nhằm thu thập logs rồi gửi đến Loki

- Grafana Loki: Lưu trữ và lập index là 1 hệ thống tổng hợp log, nó chỉ lập index cho các labels đi kèm với log

- Grafana: công cụ trực quan hoá (ngôn ngữ truy vấn LogQL)

2. EFK Stack

- FluentD > ElasticSearch > Kibana Dashboard

- FluetD/FluentBit sẽ được cài đăt và thu thập log từ các application 

- ElasticSeach: Lưu trữ và lập index, là 1 bộ công cụ tìm kiếm và phân tích phân tán, nhận log từ các <br> collecter và shipper rồi lưu trữ lại

- Kibana: kết nối tới ElasticSearch, dữ liệu trực quan hoá

3. ELK Stack

- Beats > Logstash > Kibana

- Beats: thu thập dữ liệu, nhóm các agent nhẹ được cài đặt trên các server thu thập các loại dữ liệu khác nhau

- Logstash: xử lý và chuyển hướng dữ liệu được thu thập từng Beats

- Kibana: kết nối tới ElasticSearch, dữ liệu trực quan hoá

4. VEK stack

- Sources: Lấy logs từ container, Log file, K8S, Databse, socket v.v

- Transforms: Định dạng lại dữ liệu, chuyển đổi và chuyển hoá dữ liệu

- Sinks: Gửi dữ liệu về ElasticSearch để trực quan hoá dữ liệu trên Kibana

## 8. Phân tích chi tiết các logging stack

### 8.1 Công cụ phù hợp với từng vấn đề và yêu cầu bài toán

### Elasticsearch 

1. Bản chất/kiến trúc

- Document store dùng Lucene + doc_values; mapping/schema-on-write

2. Điểm manh

- Tìm kiến full-text mạnh aggregations đa chiều, Query DSL giàu, hệ sinh thái Elastic/Kibana/ES

3. Hạn chế 

- Chi phí ghi & lưu trữ(tokenize, build index, segment): JVM:GC quản trị shard/ILM phức tạp

4. Khi dùng

- Điều tra chuyên sâu, audit/security, phân tích nhiều chiều, cần truy vấn kêt hợp text + field

### Loki

1. Bản chất/kiến trúc

- Chỉ lables nội dung log nén thành chunks trên object storage

2. Điểm manh

- Giá rẻ: lưu trữ rẻ/dài hạn(S3/GCS) scale ngang đươn giản; tích hợp Grafana/metrics/traces

3. Hạn chế 

- Tìm kiếm theo nội dung phải quét chunk; nhạy cảm với label cardinality cao

4. Khi dùng

- Khối lượng log rất lớn, retention dài; truy vấn chủ đạo theo nhãn/service/env và lọc theo dòng 

## 9. Triển khai hệ thống Log ở hạ tầng nào ?

- Triển khai Vitualtilizon, container(Docker), Kubernetes

## 10. Thiết lập hạ tầng ban đầu

## 11. Triển khai dự án Fullstack

## 12. Cài đặt Elasticsearch và Kibana

``` bash
# Set thời gian theo VietNam
sudo timedatectl set-timezone Asia/Ho_Chi_Minh

# Kiểm tra múi giờ hiện tại
timedatectl

# hoặc 
Date

# Kiểm tra các múi giờ có sẵn 
timedatectl list-timezones | grep Asia
```

### Cài đặt Elasticsearch

1. Cài đặt Elasticsearch

``` bash
$ curl -fsSL https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo gpg --dearmor -o /usr/share/keyrings/elastic.gpg
$ echo "deb [signed-by=/usr/share/keyrings/elastic.gpg] https://artifacts.elastic.co/packages/9.x/apt stable main" | sudo tee /etc/apt/sources.list.d/elastic-9.x.list
$ sudo apt update -y
$ sudo apt install elasticsearch
```
2. Chỉnh sửa cấu hình Elasticsearch

``` bash
$ vi /etc/elasticsearch/elasticsearch.yml 
```

3. Tìm và sửa các nội dung

``` yml
cluster.name: elasticsearch-devopseduvn
network.host: 0.0.0.0
http.port: 9200
xpack.security.enabled: true
xpack.monitoring.collection.enabled: true
```

4. Khởi động và kiểm tra trạng thái Elasticsearch service

``` bash
$ sudo systemctl start elasticsearch
$ sudo systemctl enable elasticsearch
$ sudo systemctl status elasticsearch
```

5. Đặt mật khẩu cho tài khoản Elasticsearch

``` bash
$ sudo /usr/share/elasticsearch/bin/elasticsearch-reset-password -u elastic -i
>> KHFDPeU6
```

6. Kiểm tra trạng thái hoạt động của Elasticsearch

``` bash
$ curl --cacert /etc/elasticsearch/certs/http_ca.crt -u elastic:KHFDPeU6 https://localhost:9200
```

7. Cài đặt Kibana

``` bash
$ sudo apt update -y
$ sudo apt install kibana -y
```

8. Chỉnh sửa cấu hình Kibana

``` bash
$ vi /etc/kibana/kibana.yml
```

9. Tìm và sửa các nội dung như dưới đây:

``` yml 
server.name: "kibana-devopseduvn"
server.host: "0.0.0.0"
server.port: 5601
elasticsearch.hosts: ["http://localhost:9200"]
elasticsearch.ssl.certificateAuthorities: ["/etc/kibana/certs/http_ca.crt"]
```

- Sau đó hãy truy cập với http://ip-server:5601

10. Copy và phân quyền file xác thực HTTPS của elasticsearch

``` bash
$ sudo mkdir -p /etc/kibana/certs
$ sudo cp /etc/elasticsearch/certs/http_ca.crt /etc/kibana/certs/
$ sudo chown -R kibana:kibana /etc/kibana/certs/
```

11. Khởi động và kiểm tra trạng thái Kibana service

### nếu bị lỗi thì hãy dùng bước dưới còn không thì restart bình thường

``` bash
sudo mkdir -p /var/log/kibana
sudo mkdir -p /var/lib/kibana
sudo chown -R kibana:kibana /var/log/kibana
sudo chown -R kibana:kibana /var/lib/kibana
sudo chmod -R 755 /var/log/kibana /var/lib/kibana
```

``` bash
$ sudo systemctl restart kibana
$ sudo systemctl enable kibana
$ sudo systemctl status kibana
```

12. Tạo token xác thực

``` bash
$ sudo /usr/share/elasticsearch/bin/elasticsearch-create-enrollment-token -s kibana
```

13. Lấy verification code

``` bash
$ sudo /usr/share/kibana/bin/kibana-verification-code
```

14. Thêm Index sample thử xem hệ thống đã hoạt động chưa

``` bash
curl --cacert /etc/elasticsearch/certs/http_ca.crt 
  -u elastic:KHFDPeU6 
  -X PUT "https://localhost:9200/devopseduvn-logs-000001" 
  -H "Content-Type: application/json" 
  -d '{
    "settings": {
      "number_of_shards": 1,
      "number_of_replicas": 0,
      "index.translog.durability": "request",
      "index.refresh_interval": "1s"
    },
    "mappings": {
      "properties": {
        "@timestamp":        { "type": "date" },
        "service":           { "type": "keyword" },
        "env":               { "type": "keyword" },
        "level":             { "type": "keyword" },
        "message":           { "type": "text" },
        "host.ip":           { "type": "ip" },
        "http.status_code":  { "type": "integer" }
      }
    }
  }'
```

15. Ghi thử log mẫu

``` bash
curl --cacert /etc/elasticsearch/certs/http_ca.crt 
  -u elastic:KHFDPeU6 
  -X POST "https://localhost:9200/devopseduvn-logs-000001/_doc" 
  -H "Content-Type: application/json" 
  -d '{
    "@timestamp": "2025-08-12T00:10:00Z",
    "service": "devopseduvn-api",
    "env": "prod",
    "level": "info",
    "message": "health check OK",
    "host": {
      "ip": "192.168.1.10"
    },
    "http": {
      "status_code": 200
    }
  }'
```

16. Thành công truy cập trên trình duyệt vào Kibana với địa chỉ http://ip_server:5601

### Config bonus

1. Cấu hình persistent cluster settings trong Elasticsearch, thiết lập các ngưỡng cảnh báo dung lượng ổ đĩa và bảo vệ dữ liệu khi ổ đĩa sắp đầy

``` bash
curl --cacert /etc/elasticsearch/certs/http_ca.crt 
  -u elastic:KHFDPeU6 
  -X PUT "https://localhost:9200/_cluster/settings" 
  -H "Content-Type: application/json" 
  -d '{
    "persistent": {
      "action.destructive_requires_name": "true",
      "cluster.routing.allocation.disk.watermark.low":  "85%",
      "cluster.routing.allocation.disk.watermark.high": "90%",
      "cluster.routing.allocation.disk.watermark.flood_stage": "95%"
    }
  }'
```

### Lưu ý quan trọng:

- Đây là cấu hình persistent, nghĩa là vẫn giữ nguyên sau khi restart cluster.

- Nếu bạn chỉ muốn test tạm thời, có thể đổi “persistent” thành “transient“.

- Nếu log tăng quá nhanh, tốt nhất là:

- Tăng dung lượng ổ đĩa.

- Hoặc bật ILM (Index Lifecycle Management) để tự động xóa log cũ.

### Kinh nghiệm thực tế

- Trong môi trường logging lớn (Elastic, Kibana, Beats, Vector, Loki…):

- Bắt buộc set watermark, nếu không:

- Ổ đĩa đầy → Elasticsearch dừng ghi log.

- Hoặc xấu hơn → Cluster bị red status.

### Nên kết hợp:

- ILM policy → Tự động xóa index cũ.

- Watermark → Bảo vệ khi log tăng bất ngờ.

- Monitor → Alert khi dung lượng > 80%.

2. Snapshot (backup) bắt buộc với single-node (chú ý nên sử dụng disk khác mount vào server để đảm bảo dữ liệu)

``` bash
$ sudo mkdir -p /mnt/es-snapshots
$ sudo chown elasticsearch:elasticsearch /mnt/es-snapshots
```
- Thêm cấu hình trong file /etc/elasticsearch/elasticsearch.yml 

``` bash
path.repo: ["/mnt/es-snapshots"]
```

- Restart lại Elasticsearch

``` bash
sudo systemctl restart elasticsearch
```

- Đăng ký snapshot repository

``` bash
curl --cacert /etc/elasticsearch/certs/http_ca.crt 
  -u elastic:KHFDPeU6 
  -X PUT "https://localhost:9200/_snapshot/devopseduvn_repo" 
  -H "Content-Type: application/json" 
  -d '{
    "type": "fs",
    "settings": {
      "location": "/mnt/es-snapshots",
      "compress": true
    }
  }'
```

- Tạo snapshot

``` bash
curl --cacert /etc/elasticsearch/certs/http_ca.crt 
  -u elastic:KHFDPeU6 
  -X PUT "https://localhost:9200/_snapshot/devopseduvn_repo/snap_$(date +%Y%m%d_%H%M%S)?wait_for_completion=true"
```

3. Tạo policy SLM hàng ngày (1:00)

``` bash
curl --cacert /etc/elasticsearch/certs/http_ca.crt 
  -u elastic:KHFDPeU6 
  -X PUT "https://localhost:9200/_slm/policy/daily_01h" 
  -H "Content-Type: application/json" 
  -d '{
    "schedule": "0 0 1 * * ?",
    "name": "<daily-{now/d}>",
    "repository": "local_fs",
    "config": { "include_global_state": true },
    "retention": {
      "expire_after": "30d",
      "min_count": 7,
      "max_count": 60
    }
  }'
```

- Các câu lệnh kiểm tra

``` bash
# Xem policy
curl --cacert /etc/elasticsearch/certs/http_ca.crt -u elastic:KHFDPeU6 
  -X GET "https://localhost:9200/_slm/policy/daily_01h?pretty"

# Thực thi ngay (test)
curl --cacert /etc/elasticsearch/certs/http_ca.crt -u elastic:KHFDPeU6 
  -X POST "https://localhost:9200/_slm/policy/daily_01h/_execute?pretty"

# Xem lịch sử/ trạng thái SLM
curl --cacert /etc/elasticsearch/certs/http_ca.crt -u elastic:KHFDPeU6 
  -X GET "https://localhost:9200/_slm/status?pretty"
```

4. Bật slowlog để lưu ý chỉ số bất thường

``` bash
# Indexing slowlog
curl --cacert /etc/elasticsearch/certs/http_ca.crt -u elastic:KHFDPeU6 
  -X PUT "https://localhost:9200/devopseduvn-logs-*/_settings" 
  -H "Content-Type: application/json" -d '{
    "index.indexing.slowlog.threshold.index.warn": "1s",
    "index.indexing.slowlog.threshold.index.info": "500ms",
    "index.indexing.slowlog.source": "1000"
  }'

# Search slowlog
curl --cacert /etc/elasticsearch/certs/http_ca.crt -u elastic:KHFDPeU6 
  -X PUT "https://localhost:9200/devopseduvn-logs-*/_settings" 
  -H "Content-Type: application/json" -d '{
    "index.search.slowlog.threshold.query.warn": "2s",
    "index.search.slowlog.threshold.fetch.warn": "1s"
  }'
```
