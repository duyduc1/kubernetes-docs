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
>> DUYDUC123
```

6. Kiểm tra trạng thái hoạt động của Elasticsearch

``` bash
$ curl --cacert /etc/elasticsearch/certs/http_ca.crt -u elastic:DUYDUC123 https://localhost:9200
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
curl -u elastic:DUYDUC123 \
  -X PUT "https://localhost:9200/devopseduvn-logs-000001" \
  -H "Content-Type: application/json" \
  -k \
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
curl --cacert /etc/elasticsearch/certs/http_ca.crt \
  -u elastic:DUYDUC123 \
  -X POST "https://localhost:9200/devopseduvn-logs-000001/_doc" \
  -H "Content-Type: application/json" \
  -d '{
    "@timestamp": "2025-08-12T00:10:00Z",
    "service": "devopseduvn-api",
    "env": "prod",
    "level": "info",
    "message": "health check OK",
    "host": { "ip": "192.168.230.150" },
    "http": { "status_code": 200 }
  }'

```

16. Thành công truy cập trên trình duyệt vào Kibana với địa chỉ http://ip_server:5601

### Config bonus

1. Cấu hình persistent cluster settings trong Elasticsearch, thiết lập các ngưỡng cảnh báo dung lượng ổ đĩa và bảo vệ dữ liệu khi ổ đĩa sắp đầy

``` bash
curl --cacert /etc/elasticsearch/certs/http_ca.crt \
  -u elastic:DUYDUC123 \
  -X PUT "https://localhost:9200/_cluster/settings" \ 
  -H "Content-Type: application/json" \
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
curl --cacert /etc/elasticsearch/certs/http_ca.crt \
  -u elastic:DUYDUC123 \
  -X PUT "https://localhost:9200/_snapshot/devopseduvn_repo" \ 
  -H "Content-Type: application/json" \
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
curl --cacert /etc/elasticsearch/certs/http_ca.crt \ 
  -u elastic:DUYDUC123 \
  -X PUT "https://localhost:9200/_snapshot/devopseduvn_repo/snap_$(date +%Y%m%d_%H%M%S)?wait_for_completion=true" \
```

3. Tạo policy SLM hàng ngày (1:00)

``` bash
curl --cacert /etc/elasticsearch/certs/http_ca.crt \
  -u elastic:DUYDUC123 \
  -X PUT "https://localhost:9200/_slm/policy/daily_01h" \
  -H "Content-Type: application/json" \
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
curl --cacert /etc/elasticsearch/certs/http_ca.crt \
  -u elastic:DUYDUC123 \
  -X GET "https://localhost:9200/_slm/policy/daily_01h?pretty"

# Thực thi ngay (test)
curl --cacert /etc/elasticsearch/certs/http_ca.crt \ 
  -u elastic:DUYDUC123 \
  -X POST "https://localhost:9200/_slm/policy/daily_01h/_execute?pretty"

# Xem lịch sử/ trạng thái SLM
curl --cacert /etc/elasticsearch/certs/http_ca.crt \
  -u elastic:DUYDUC123 \
  -X GET "https://localhost:9200/_slm/status?pretty"
```

4. Bật slowlog để lưu ý chỉ số bất thường

``` bash
# Indexing slowlog
curl --cacert /etc/elasticsearch/certs/http_ca.crt \
  -u elastic:DUYDUC123 \
  -X PUT "https://localhost:9200/devopseduvn-logs-*/_settings" \
  -H "Content-Type: application/json" -d '{
    "index.indexing.slowlog.threshold.index.warn": "1s",
    "index.indexing.slowlog.threshold.index.info": "500ms",
    "index.indexing.slowlog.source": "1000"
  }'

# Search slowlog
curl --cacert /etc/elasticsearch/certs/http_ca.crt \
  -u elastic:DUYDUC123 \
  -X PUT "https://localhost:9200/devopseduvn-logs-*/_settings" \
  -H "Content-Type: application/json" -d '{
    "index.search.slowlog.threshold.query.warn": "2s",
    "index.search.slowlog.threshold.fetch.warn": "1s"
  }'
```
## 13. Các thành phần và chức năng trên kibana

1. Elasticsearch

- Dùng để truy cập API và tools để tạo ra các search enginee hoặc để quản lý <br> dữ liệu đã index

2. Observability

- Gộp logs, metric, traces và system và 1 giao diện để giám sát

3. Security

- Quản lý bảo mật và phát hiện các mối đe doạ ảnh hưởng tới hệ thống

4. Analytics

- Khai thác, phân tích và trực quan hoá dữ liệu qua các bộ phân tích cụ thể

## 14. Tìm hiểu và cài đặt cấu hình công cụ log agent trên server dự án

### Công nghệ thu thập log

- Vector

- Beat

- FluentBit/FluentD

### Cài đặt Vector

``` bash
bash -c "$(curl -L https://setup.vector.dev)"
sudo apt-get install -y vector
sudo systemctl enable --now vector
```

### File cấu hình nằm trong /etc/vector/vector.yml

``` yml
#                                    __   __  __
#                                      / / / /
#                                      V / / /
#                                      _/  /
#
#                                    V E C T O R
#                                   Configuration
#
# ------------------------------------------------------------------------------
# Website: https://vector.dev
# Docs: https://vector.dev/docs
# Chat: https://chat.vector.dev
# ------------------------------------------------------------------------------

# Change this to use a non-default directory for Vector data storage:
# data_dir: "/var/lib/vector"

# Random Syslog-formatted logs
sources:
  dummy_logs:
    type: "demo_logs"
    format: "syslog"
    interval: 1

# Parse Syslog logs
# See the Vector Remap Language reference for more info: https://vrl.dev
transforms:
  parse_logs:
    type: "remap"
    inputs: ["dummy_logs"]
    source: |
      . = parse_syslog!(string!(.message))

# Print parsed logs to stdout
sinks:
  print:
    type: "console"
    inputs: ["parse_logs"]
    encoding:
      codec: "json"
      json:
        pretty: true

# Vector's GraphQL API (disabled by default)
# Uncomment to try it out with the `vector top` command or
# in your browser at http://localhost:8686
# api:
#   enabled: true
#   address: "127.0.0.1:8686"
```

## 15. Tìm hiểu cấu hình các thành phần Vector

1. Sources

- File: Thu thập file log

- Docker_logs: thu thập tất cả các log trong docker

## 16. Phân tích log dự án

``` yaml
# workflow
=> File log => phân tích log => đưa ra các phương án thu thập và format log => áp dụng quy tắc vào cấu hình
```

## 17. Config thư thập log từ dự án Backend

### Ở server triển khai dự án

``` bash
cd /etc/vector
mkdir certs

### Ở thư mục triển khai server-logging
scp -r /etc/elasticsearch/certs/http_ca.crt root@<server-triển-khai-dự-án>:/etc/vector/certs

### Ở server triển khai dự án
ls -l /etc/vector/certs
chown -R vector. /etc/vector

mv vector.yaml vector.yaml.orgin
nano vector.yaml
```

``` yaml
## Cấu hình trong bài giảng

data_dir: /var/lib/vector

sources:
  backend_order:
    type: file
    include:
      - /var/log/java/backend.log
    ignore_older_secs: 0
    multiline:
      start_pattern: '^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}(?:Z|[+-]\d{2}:\d{2})\s'
      condition_pattern: '^(?:\s|at\s|Caused by:|Hibernate:)'
      mode: continue_through
      timeout_ms: 2000

transforms:
  enrich_env:
    type: remap
    inputs: [backend_order]
    source: |
      .message = to_string!(.message)
      if !exists(.labels) { .labels = {} }
      .labels.env = "prod"
      .input = { "type": "file", "path": "/var/log/java/backend.log" }

  parse_spring:
    type: remap
    inputs: [enrich_env]
    source: |
      m, err = parse_regex(
        .message,
        r'^(?P<ts>\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}(?:Z|[+-]\d{2}:\d{2}))\s+(?P<level>[A-Z]+)\s+(?P<pid>\d+)\s+---\s+\[(?P<app>[^\]]+)\]\s+\[(?P<thr>[^\]]+)\]\s+(?P<logger>[^:]+?)\s*:\s*(?P<msg>.*)$'
      )

      if err == null {
        .timestamp = parse_timestamp!(m.ts, format: "%+")
        if !exists(.log) { .log = {} }
        .log.level = downcase!(m.level)
        if !exists(.process) { .process = {} }
        .process.pid = to_int!(m.pid)
        .labels.app = m.app
        if !exists(.thread) { .thread = {} }
        .thread.name = m.thr
        .logger = m.logger
        .message = m.msg

        if !exists(.event) { .event = {} }
        logger_s = to_string(m.logger)
        if starts_with(logger_s, "org.hibernate") {
          .event.dataset = "spring.hibernate"
        } else if starts_with(logger_s, "o.s") || starts_with(logger_s, "org.springframework") {
          .event.dataset = "spring.framework"
        } else if starts_with(logger_s, "o.a.") || starts_with(logger_s, "org.apache.") {
          .event.dataset = "spring.framework"  # Tomcat/Catalina/Apache
        } else {
          .event.dataset = "spring.app"
        }
      } else {
        msg_s = to_string!(.message)
        if starts_with(msg_s, "Hibernate: ") {
          if !exists(.event) { .event = {} }
          .event.dataset = "hibernate.sql"
          if !exists(.log) { .log = {} }
          .log.level = "info"
          if !exists(.sql) { .sql = {} }
          .sql.query = replace(msg_s, r'^Hibernate:\s*', "")
        } else {
          if !exists(.event) { .event = {} }
          .event.dataset = "spring.continuation"
        }
      }

      p, perr = parse_regex(.message, r'Tomcat initialized with port (?P<port>\d+)')
      if perr == null {
        if !exists(.http) { .http = {} }
        if !exists(.http.server) { .http.server = {} }
        .http.server.port = to_int!(p.port)
      }

  trace_and_context:
    type: remap
    inputs: [parse_spring]
    source: |
      t, terr = parse_regex(.message, r'(?:^|[\s,])trace_id=(?P<trace>[A-Za-z0-9\-_]+)')
      if !exists(.trace) { .trace = {} }
      if terr == null { .trace.id = t.trace } else { .trace.id = uuid_v4() }

      if !exists(.service) { .service = {} }
      app_s = "unknown-service"
      if exists(.labels) && exists(.labels.app) { app_s = to_string!(.labels.app) }
      lg = to_string!(.logger)
      if contains(lg, ".") {
        parts = split(lg, ".")
        if length(parts) > 2 {
          .service.name = parts[2]
        } else {
          .service.name = app_s
        }
      } else {
        .service.name = app_s
      }

  pii_mask:
    type: remap
    inputs: [trace_and_context]
    source: |
      if exists(.message) {
        .message = to_string!(.message)
        .message = replace(.message, r'([A-Za-z0-9._%+\-])([A-Za-z0-9._%+\-]*?)@([A-Za-z0-9.\-]+\.[A-Za-z]{2,})', "$$1***@$$3")
        .message = replace(.message, r'\b(\d{4})\d{8,11}(\d{4})\b', "$$1********$$2")
        .message = replace(.message, r'(?i)(authorization:?\s*bearer\s+)[A-Za-z0-9\-\._]+', "$$1******")
        .message = replace(.message, r'(?i)(api[_\-]?key|token|secret)["\s=:]*[A-Za-z0-9\-\._]{6,}', "$$1=******")
      }
      if exists(.sql) && exists(.sql.query) {
        .sql.query = to_string!(.sql.query)
        .sql.query = replace(.sql.query, r'\b(\d{4})\d{8,11}(\d{4})\b', "$$1********$$2")
      }

  filter_debug_prod:
    type: filter
    inputs: [pii_mask]
    condition: '!(.labels.env == "prod" && .log.level == "debug")'

  route_by_dataset:
    type: route
    inputs: [filter_debug_prod]
    route:
      to_app: '.event.dataset == "spring.app"'
      to_framework: '.event.dataset == "spring.framework"'
      to_hibernate: '.event.dataset == "hibernate.sql" || .event.dataset == "spring.hibernate"'
      to_misc: '.event.dataset == "spring.continuation"'

sinks:
  es_app:
    type: elasticsearch
    inputs: [route_by_dataset.to_app]
    endpoints: ["https://10.1.0.13:9200"]
    auth:
      strategy: basic
      user: elastic
      password: "DUYDUC123"
    tls:
      ca_file: "/etc/vector/certs/http_ca.crt"
    bulk:
      index: "ecommerce-backend-app-%Y-%m-%d"

  es_framework:
    type: elasticsearch
    inputs: [route_by_dataset.to_framework]
    endpoints: ["https://10.1.0.13:9200"]
    auth:
      strategy: basic
      user: elastic
      password: "DUYDUC123"
    tls:
      ca_file: "/etc/vector/certs/http_ca.crt"
    bulk:
      index: "ecommerce-backend-framework-%Y-%m-%d"

  es_hibernate:
    type: elasticsearch
    inputs: [route_by_dataset.to_hibernate]
    endpoints: ["https://10.1.0.13:9200"]
    auth:
      strategy: basic
      user: elastic
      password: "DUYDUC123"
    tls:
      ca_file: "/etc/vector/certs/http_ca.crt"
    bulk:
      index: "ecommerce-backend-hibernate-%Y-%m-%d"

  es_misc:
    type: elasticsearch
    inputs: [route_by_dataset.to_misc]
    endpoints: ["https://10.1.0.13:9200"]
    auth:
      strategy: basic
      user: elastic
      password: "DUYDUC123"
    tls:
      ca_file: "/etc/vector/certs/http_ca.crt"
    bulk:
      index: "ecommerce-backend-misc-%Y-%m-%d"

  blackhole_unmatched:
    type: blackhole
    inputs: [route_by_dataset._unmatched]

  stdout_debug:
    type: console
    inputs:
      - route_by_dataset.to_app
      - route_by_dataset.to_framework
      - route_by_dataset.to_hibernate
      - route_by_dataset.to_misc
    target: stdout
    encoding:
      codec: json
```

### Kiểm tra cấu trúc

``` bash
### kill tiến trình app cũ đang chạy
ps -ef| grep java
kill -9 <PID>

echo > /var/log/java/dự-án.log
cat /var/log/java/dự-án.log

### câu lệnh kiểm tra
vector validate /etc/vector/vector.yaml

### restart lại vector
systemctl restart vector.service
systemctl status vector.service

###  chạy lại ứng dụng java
nohup java -jar target/thư-mục-build-của-dự-án.jar > /var/log/java/ecom-backend.log 2>&1 &
```

### Tiếp tục với dashboard kibana

``` yaml
1. Vào Manament => index Management => sẽ xuất hiện các index sau khi cấu hình

2. Vào Data Views của Kibana => create Data view

- Name : devopseduvn-logs (example)

- Index pattern : devopseduvn-logs-* (example)

3. Save data view to Kibana

### Làm tương tự để tạo các dataviews khác
```

## 18. Config thu thập log từ dự án Frontend Docker

``` bash
cd /etc/vector/
mkdir conf.d
chown -R vector. /etc/vector
mv vector.yaml conf.d/
mv conf.d/vector.yaml conf.d/ecommerce-backend.yaml

### Tạo file ecommerce-frontend.yaml
touch conf.d/ecommerce-frontend.yaml

### Cập nhật nội dung service vector
nano /lib/systemd/system/vector.service
```

``` bash
[Unit]
Description=Vector
Documentation=https://vector.dev
After=network-online.target
Requires=network-online.target

[Service]
User=root
# Group=vector
ExecStartPre=/usr/bin/vector validate --config-dir /etc/vector/conf.d
ExecStart=/usr/bin/vector --config-dir /etc/vector/conf.d
ExecReload=/usr/bin/vector validate --no-environment
ExecReload=/bin/kill -HUP $MAINPID
Restart=always
AmbientCapabilities=CAP_NET_BIND_SERVICE
EnvironmentFile=/etc/default/vector
StartLimitInterval=10
StartLimitBurst=5

[Install]
WantedBy=multi-user.target
```

``` yaml
data_dir: /var/lib/vector

sources:
  fe_docker:
    type: docker_logs
    docker_host: "unix:///var/run/docker.sock"
    include_containers:
      - "frontend"

transforms:
  fe_enrich_env:
    type: remap
    inputs: [fe_docker]
    source: |
      .message = to_string!(.message)
      if !exists(.labels) { .labels = {} }
      .labels.env = "prod"
      if !exists(.service) { .service = {} }
      .service.name = "ecommerce-frontend"
      if !exists(.container) { .container = {} }
      if exists(.container_name) { .container.name = to_string!(.container_name) }
      if exists(.image) { .container.image = to_string!(.image) }

  fe_parse_nginx:
    type: remap
    inputs: [fe_enrich_env]
    source: |
      msg = to_string!(.message)

      if starts_with(msg, "/docker-entrypoint.sh:") || contains(msg, "/docker-entrypoint.d/") {
        if !exists(.event) { .event = {} }
        .event.dataset = "nginx.entrypoint"
        if !exists(.log) { .log = {} }
        .log.level = "info"

      } else {
        m1, e1 = parse_regex(msg, r'^(?P<ts>\d{4}/\d{2}/\d{2}\s\d{2}:\d{2}:\d{2})\s+\[(?P<lvl>[a-z]+)\]\s+(?P<pid>\d+)#(?P<tid>\d+):\s*(?P<err>.*)$')
        if e1 == null {
          .timestamp = parse_timestamp!(m1.ts, format: "%Y/%m/%d %H:%M:%S")
          if !exists(.log) { .log = {} }
          .log.level = to_string(m1.lvl)
          if !exists(.process) { .process = {} }
          .process.pid = to_int!(m1.pid)
          if !exists(.thread) { .thread = {} }
          .thread.id = to_int!(m1.tid)
          .message = m1.err
          if !exists(.event) { .event = {} }
          .event.dataset = "nginx.error"

        } else {
          m2, e2 = parse_regex(
            msg,
            r'^(?P<remote_addr>\S+)\s+\S+\s+\S+\s+\[(?P<time>[^\]]+)\]\s+"(?P<method>\S+)\s+(?P<path>\S+)\s+(?P<protocol>[^"]+)"\s+(?P<status>\d{3})\s+(?P<body_bytes>\d+)\s+"(?P<referrer>[^"]*)"\s+"(?P<ua>[^"]*)"'
          )
          if e2 == null {
            .timestamp = parse_timestamp!(m2.time, format: "%d/%b/%Y:%H:%M:%S %z")
            if !exists(.event) { .event = {} }
            .event.dataset = "nginx.access"

            if !exists(.client) { .client = {} }
            .client.ip = m2.remote_addr

            if !exists(.http) { .http = {} }
            if !exists(.http.request) { .http.request = {} }
            .http.request.method = m2.method
            .http.request.referrer = m2.referrer

            if !exists(.url) { .url = {} }
            .url.path = m2.path

            if !exists(.network) { .network = {} }
            .network.protocol = m2.protocol

            if !exists(.http.response) { .http.response = {} }
            .http.response.status_code = to_int!(m2.status)
            if !exists(.http.response.body) { .http.response.body = {} }
            .http.response.body.bytes = to_int!(m2.body_bytes)

            if !exists(.user_agent) { .user_agent = {} }
            .user_agent.original = m2.ua

          } else {
            if !exists(.event) { .event = {} }
            .event.dataset = "nginx.misc"
          }
        }
      }

  fe_pii_mask:
    type: remap
    inputs: [fe_parse_nginx]
    source: |
      if exists(.message) {
        .message = to_string(.message) ?? ""
        .message = replace(.message, r'([A-Za-z0-9._%+\-])([A-Za-z0-9._%+\-]*?)@([A-Za-z0-9.\-]+\.[A-Za-z]{2,})', "$$1***@$$3")
        .message = replace(.message, r'\b(\d{4})\d{8,11}(\d{4})\b', "$$1********$$2")
        .message = replace(.message, r'(?i)(authorization:?\s*bearer\s+)[A-Za-z0-9\-\._]+', "$$1******")
        .message = replace(.message, r'(?i)(api[_\-]?key|token|secret)["\s=:]*[A-Za-z0-9\-\._]{6,}', "$$1=******")
      }
      if exists(.http) && exists(.http.request) && exists(.http.request.referrer) {
        .http.request.referrer = to_string(.http.request.referrer) ?? ""
        .http.request.referrer = replace(.http.request.referrer, r'([A-Za-z0-9._%+\-])([A-Za-z0-9._%+\-]*?)@([A-Za-z0-9.\-]+\.[A-Za-z]{2,})', "$$1***@$$3")
      }
      if exists(.user_agent) && exists(.user_agent.original) {
        .user_agent.original = to_string(.user_agent.original) ?? ""
        .user_agent.original = replace(.user_agent.original, r'\b(\d{4})\d{8,11}(\d{4})\b', "$$1********$$2")
      }

  fe_filter_debug_prod:
    type: filter
    inputs: [fe_pii_mask]
    condition: '!(.labels.env == "prod" && .log.level == "debug")'

  fe_route:
    type: route
    inputs: [fe_filter_debug_prod]
    route:
      to_access:      '.event.dataset == "nginx.access"'
      to_error:       '.event.dataset == "nginx.error"'
      to_entrypoint:  '.event.dataset == "nginx.entrypoint"'
      to_misc:        '.event.dataset == "nginx.misc"'

sinks:
  es_fe_access:
    type: elasticsearch
    inputs: [fe_route.to_access]
    endpoints: ["https://10.1.0.13:9200"]
    auth: { strategy: basic, user: elastic, password: "DUYDUC123" }
    tls:  { ca_file: "/etc/vector/certs/http_ca.crt" }
    bulk: { index: "ecommerce-frontend-nginx-access-%Y-%m-%d" }

  es_fe_error:
    type: elasticsearch
    inputs: [fe_route.to_error]
    endpoints: ["https://10.1.0.13:9200"]
    auth: { strategy: basic, user: elastic, password: "DUYDUC123" }
    tls:  { ca_file: "/etc/vector/certs/http_ca.crt" }
    bulk: { index: "ecommerce-frontend-nginx-service-%Y-%m-%d" }

  es_fe_entrypoint:
    type: elasticsearch
    inputs: [fe_route.to_entrypoint]
    endpoints: ["https://10.1.0.13:9200"]
    auth: { strategy: basic, user: elastic, password: "DUYDUC123" }
    tls:  { ca_file: "/etc/vector/certs/http_ca.crt" }
    bulk: { index: "ecommerce-frontend-nginx-init-%Y-%m-%d" }

  es_fe_misc:
    type: elasticsearch
    inputs: [fe_route.to_misc]
    endpoints: ["https://10.1.0.13:9200"]
    auth: { strategy: basic, user: elastic, password: "DUYDUC123" }
    tls:  { ca_file: "/etc/vector/certs/http_ca.crt" }
    bulk: { index: "ecommerce-frontend-nginx-misc-%Y-%m-%d" }

  stdout_fe_debug:
    type: console
    inputs:
      - fe_route.to_access
      - fe_route.to_error
      - fe_route.to_entrypoint
      - fe_route.to_misc
    target: stdout
    encoding:
      codec: json

  blackhole_fe_unmatched:
    type: blackhole
    inputs: [fe_route._unmatched]
```

``` bash
systemctl daemon-reload
systemctl restart vector.service
docker restart frontend
```

## 19. Tìm hiểu dashboard kibana


## 20. Thiết lập dashboard Kibana theo dõi dự án

### Horiontal

1. Chọn vào dashboard

2. Create a dashboard

3. Create vitualization

4. kéo timestamp qua Horiontal axis

### Vertical axis

1. Nhấn Add or drag and drop a field

## 21. Phân quyền trên Kibana như thế nào ?

### 1. Cách làm series 

- Thực tế 

- Tài liệu chính thức 

### 2. Setup

1. Vào management -> tab Security -> chọn Roles

## 22. Thực hiện phân quyền trên Kibana

### 1. Setup spaces trên header của Kibana hover vào Spaces (Ô có màu xanh lá) 

1. Chọn vào Manage spaces 

2. Create space

3. Select solution view

- name: (Dev Team) 

- Ở Select solution view: hãy chọn Classic

4. Set feature visibility

- ở Analytics chỉ giữ lại (Disconver, Dashboard)

- disable Security

- ở Managemet giữ lại (Dev tools, Data view Manament, Saved Query Management)

5. Create

### 2. Setup Roles

1. Vào Management => ở mục Security => Roles => Create Roles 

2. Điền các thông tin (Cluster privileges)

- Role name: Name-example

- Remote cluster privileges: Monitor (cho team dev hoặc tuỳ vị trí)

3. Index privileges

- Tiến hành gắn các index đã thêm ở (indices) và ở (Privileges) chọn read, monitor, view_index_metadata

4. Application layer

- click Asign to space

- Assign role to spaces

- Select space: chọn spaces đã tạo từ trước (Dev Team)

- Chọn Customize 

- Đối với Anlytics (Discover & Dashboard hãy để Read)

- Đối với Elasticsearch (Để All cho tất cả)

- Đối với Observability (Để All tất cả)

- Đối với Management (Dev Tools & Data view management & Saved Query Management để All)

### 3. Setup User

- Điền Username: dev-team (example)

- Password: Vuduyduc28042002@ (example)

- Roles: Chọn Roles đã setup ở bước 2

### 4. Kiểm tra với Kibana với dashboard mới 

- Vào discoverry và craete dataview

## 23. Các cách để gửi cảnh báo log dự án

### Tầng vectir

- Cấu hình/server

- Hiểu biết sâu về config vector + mindset dev

- 1 server/nhiều dự án

### Tầng elasticsearch

- Tập trung dữ liệu

- indies

- Gửi telegram

### Trên server triển khai kibana và elasticsearch

``` bash
cd /etc/kibana

### Thiết lập cấu hình sử dụng Connectors
$ ENCRYPTED_SAVED_OBJECTS_KEY=$(openssl rand -base64 32)
$ REPORTING_KEY=$(openssl rand -base64 32)
$ SECURITY_KEY=$(openssl rand -base64 32)
$ echo "ESO: $ENCRYPTED_SAVED_OBJECTS_KEY"
$ echo "RPT: $REPORTING_KEY"
$ echo "SEC: $SECURITY_KEY"
```

### Config kibana

``` bash
nano kibana.yml

# === Added for Alerting & Connectors ===
xpack.encryptedSavedObjects.encryptionKey: "9bzH4cU8XREaNvOEVXUIGVsGjPh6iv7qXXpB2Fz+D3s=" # Là key từ ESO
xpack.reporting.encryptionKey: "drFYVGIDdZ8TxFGpKqHSkrQ6fLx9yHUdl4YxvbTqOls=" # Là key từ RPT
xpack.security.encryptionKey: "kDvAPJd29Y/ApQzE0sgnO++DCFwoAlE2TCErrrMWB+E=" # Là key từ SEC

systemctl restart kibana.service
```

### Config dashboard Kibana

1. Sau khi restart ở màn hình dashboard Kibana ở phần Connectors

2. Tiến hành Create Connectors

## 24. Cấu hình gửi cảnh báo log dự án về telegram

``` bash
# Output => Gửi log về telegram

# Input => Query elastichsearch => lấy document trong index => curl

# Lấy log trong vòng 5 phút mới nhất 
```

### Hướng dẫn config telegram

1. Vào telegram tạo group

2. Sau đó tìm kiếm BotFather

3. Start

4. chat 

- /newbot

- Ecommerce bot noti (đặt tên box)

- ecommerce_develop_bot (username)

5. Sau khi xong bạn sẽ được cấp 1 message 

``` bash
Done! Congratulations on your new bot. You will find it at t.me/ecommerce_develop_bot. You can now add a description, about section and profile picture for your bot, see /help for a list of commands. By the way, when you've finished creating your cool bot, ping our Bot Support if you want a better username for it. Just make sure the bot is fully operational before you do this.

Use this token to access the HTTP API:
8326585358:AAGPImLAq7ksfXKhN-JK-40swbIPusl--R8 
Keep your token secure and store it safely, it can be used by anyone to control your bot.

For a description of the Bot API, see this page: https://core.telegram.org/bots/api
```

6. kick vào t.me/ecommerce_develop_bot và start

7. dàn token vào 8326585358:AAGPImLAq7ksfXKhN-JK-40swbIPusl--R8

8. Vào trong group ecommerce vừa tạo vào add member (@ecommerce_develop_bot)

9. add thêm user <rose> vào group chat ecommerce

10. gõ /id để lấy id của group (ví dụ: -4905389110)

### Thực hiện trên logging-server

``` bash
apt  install jq

curl -s -k \
  -u "elastic:DUYDUC123" \
  --cacert /etc/elasticsearch/certs/http_ca.crt \
  -X GET "https://10.1.0.13:9200/ecommerce-backend-*/_search?track_total_hits=true" \
  -H 'Content-Type: application/json' \
  -d '{
    "size": 50,
    "sort": [ { "timestamp": "desc" } ],
    "_source": ["timestamp","log.level","message","labels.env","labels.app","service.name"],
    "query": { "range": { "timestamp": { "gte": "now-5m", "lt": "now" } } }
  }' \
| jq -r '.hits.hits[]._source | "\(.timestamp) [\(.["log.level"] // "-")] \(.message)"'
```

### Kiểm tra gửi tin nhắn từ api telegram

``` bash
curl -s "https://api.telegram.org/bot<TOKEN-ID>/sendMessage" \
  -H "Content-Type: application/json" \
  -d "{"chat_id":"<GROUP-ID>", "text":"Test từ server"}" \

### ví dụ
curl -s "https://api.telegram.org/bot8326585358:AAGPImLAq7ksfXKhN-JK-40swbIPusl--R8/sendMessage" \
  -H "Content-Type: application/json" \
  -d '{"chat_id":"-4905389110", "text":"Test từ server"}'
```

### config notication

``` bash
cd /etc/kibana
mkdir notication
cd notication
touch lay_log_trong_5_phut.sh && chmod +x lay_log_trong_5_phut.sh
```

### Cấu hình gửi tổng số log trong vòng 5 phút về telegram

``` bash
#!/usr/bin/env bash
set -euo pipefail

# Elasticsearch Config
ES_URL="https://10.1.0.13:9200"
ES_USER="elastic"
ES_PASS="DUYDUC123"
CA_CERT="$/etc/elasticsearch/certs/http_ca.crt"

# Telegram Bot Config
BOT_TOKEN="8326585358:AAGPImLAq7ksfXKhN-JK-40swbIPusl--R8"
CHAT_ID="-4905389110"

# Kibana URL
KIBANA_URL="http://10.1.0.13:5601"

# Map DataView IDs trong discovery ở Analytics
declare -A DATA_VIEW_MAP=(
  ["ecommerce-frontend-nginx-misc"]="cb5417a1-56e4-4986-964a-34ff24c693f0" # Lấy trong dataviewId trên thank link ở phần discovery
  ["ecommerce-frontend-nginx-init"]="3b49d2b0-6b54-4ee8-a259-ce6c3fed1b51" # Lấy trong dataviewId trên thank link ở phần discovery
  ["ecommerce-backend-hibernate"]="d4879039-0d61-4268-ab1e-2f293350e853" # Lấy trong dataviewId trên thank link ở phần discovery
  ["ecommerce-backend-misc"]="805ab722-6372-49cc-a3a2-a4a752a1c92c" # Lấy trong dataviewId trên thank link ở phần discovery
  ["ecommerce-frontend-nginx-access"]="9d3a2646-850f-4773-b7a1-9f0d04d638a8" # Lấy trong dataviewId trên thank link ở phần discovery
  ["ecommerce-frontend-nginx-service"]="96295c4f-363f-47f8-8454-e31fe7ec45f5" # Lấy trong dataviewId trên thank link ở phần discovery
)

# Elasticsearch Query
ES_QUERY='{
  "size": 0,
  "track_total_hits": true,
  "query": { "range": { "timestamp": { "gte": "now-5m", "lt": "now" } } }
}'

check_and_notify() {
  local prefix="$1"
  local dataview_id="${DATA_VIEW_MAP[$prefix]}"
  local index_pattern="${prefix}-*"

  local resp total
  resp=$(curl -s -k -u "$ES_USER:$ES_PASS" --cacert "$CA_CERT" -H 'Content-Type: application/json' -X GET "$ES_URL/$index_pattern/_search" -d "$ES_QUERY")
  total=$(jq -r '.hits.total.value // 0' <<<"$resp")

  if (( total > 0 )); then
    local now_utc log_link text
    now_utc="$(date -u +"%Y-%m-%d %H:%M:%SZ")"

    log_link="${KIBANA_URL}/app/discover#/?_g=(time:(from:now-5m,to:now))&_a=(dataSource:(type:dataView,dataViewId:'${dataview_id}'))"

    text="[$prefix] Có ${total} log trong 5 phút gần nhất (tính đến ${now_utc} UTC)
Xem chi tiết tại Kibana:
${log_link}"

    curl -s -X POST "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" -d "chat_id=${CHAT_ID}" --data-urlencode "text=${text}" -d "disable_web_page_preview=true" >/dev/null 

    echo "[OK] $prefix => sent: total=$total"
  else
    echo "[INFO] $prefix => no logs in last 5m"
  fi
}

for prefix in "${!DATA_VIEW_MAP[@]}"; do
  check_and_notify "$prefix"
done
```

### Tiến hành chạy

``` bash
bash lay_log_trong_5_phut.sh

sudo chmod +x /etc/kibana/notication/lay_log_trong_5_phut.sh
sudo EDITOR=nano crontab -e
### Thêm 1 dòng vào cuối file crontab để chạy script mỗi 5 phút (ví dụ):
# chạy mỗi 5 phút, ghi log stdout/stderr vào /var/log/lay_so_log_5ph.log
SHELL=/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

*/5 * * * * /etc/kibana/notication/lay_log_trong_5_phut.sh
```

## 25. APM là gì?

### Khái niệm APM 

- Là Application Performance Monitoring/Management là tập hợp các công cụ <br> dùng để giám sát, đo lường và cải thiện hiệu năng <br> của ứng dụng từ góc nhìn người dùng cho tới backend.

### Nắm bắt vấn đề cốt lõi 

- Có vân đề gì không (lỗi/chậm/nghẽn) ?

- Vấn đề ở đâu (Endpoint, service, db) ?

- Tại sao có vấn đề (Nguyên nhân gốc rể) ?

### APM sẽ theo dõi những gì 

- Distributed tracing

- Transaction metrics 

- Error tracking & exception

- Resource & depenency

- RUM (Real User Monitoring)

- Profiling

## 26. Thiết lập hệ thống APM cho backend

### Thực hiện trên logging-server

``` bash
sudo apt update -y && sudo apt install apm-server -y

cd /etc/apm-server/
cp apm-server.yml apm-server.yml.org

mkdir -p /etc/apm-server/certs/
cp /etc/elasticsearch/certs/http_ca.crt /etc/apm-server/certs/
chown -R apm-server. /etc/apm-server/
nano apm-server.yml
```

#### Nội dung apm-server.yml

``` yml
apm-server:
  host: "0.0.0.0:8200"
  secret_token: "change_this_token"

output.elasticsearch:
  hosts: ["https://10.1.0.13:9200"]
  username: "elastic"
  password: "DUYDUC123"
  ssl:
    certificate_authorities: ["/etc/apm-server/certs/http_ca.crt"]
```

#### Run nội dung 

``` bash
systemctl start apm-server
systemctl status apm-server
```

### Thực hiện trên dev-server

#### Tải file elastic-apm-agent (nếu cài trực tiếp từ link chính thức không thành công)

``` bash
cd /home/dev/Springboot-React-Ecommerce/Ecommerce-Backend
curl -L -o elastic-apm-agent.jar \
  https://repo1.maven.org/maven2/co/elastic/apm/elastic-apm-agent/1.49.0/elastic-apm-agent-1.49.0.jar

file elastic-apm-agent.jar
```

#### Chạy file jar

``` bash
java -javaagent:./elastic-apm-agent.jar -Dserver.port=8081 -Delastic.apm.environment=dev -Delastic.apm.service_name=ecommerce-backend-2 -Delastic.apm.server_url=http://10.1.0.13:8200 -jar target/ecom-proj-0.0.1-SNAPSHOT.jar

### hoặc nếu muốn chạy log vào cả file /var/log/java/backend.log

java -javaagent:./elastic-apm-agent.jar \
  -Delastic.apm.environment=dev \
  -Delastic.apm.service_name=ecommerce-backend-2 \
  -Delastic.apm.server_url=http://10.1.0.13:8200 \
  -Dserver.port=8080 \
  -jar target/ecom-proj-0.0.1-SNAPSHOT.jar \
  2>&1 | tee -a /var/log/java/backend.log

### Lưu ý nếu chạy bằng service systemd 

[Service]
Type=simple
User=root
Restart=always
WorkingDirectory=/home/dev/Springboot-React-Ecommerce/Ecommerce-Backend
ExecStart=/usr/bin/java \
  -javaagent:./elastic-apm-agent.jar \
  -Delastic.apm.environment=dev \
  -Delastic.apm.service_name=ecommerce-backend-2 \
  -Delastic.apm.server_url=http://10.1.0.13:8200 \
  -Dserver.port=8080 \
  -jar target/ecom-proj-0.0.1-SNAPSHOT.jar

StandardOutput=append:/var/log/java/backend.log
StandardError=append:/var/log/java/backend.log
```

- Trong Index Manager của Kibana qua phần Data Streams sẽ thấy trả về các metrics APM 

- Vào trong phần Application của Observarbility (Sẽ thấy được ứng dụng ecommerce-backend-2 )

- Vào bên trong ecommerce-backend-2 để xem rõ các chỉ số 

## 27. Phân tích chi tiết hệ thống

- Latency: Dùng để đo performance 

- Throughput: Đo lượng traffic 

- Failed Transaction rate

- Transactions: cụ thể các endpoint xảy ra vấ đề 

- Error: Điều tra gốc rể

## 28. Thiết lập cảnh báo APM gửi về Telegram

### Thực hiện trên Logging-server

``` bash
cd /etc/apm-server/
mkdir notifications
cd notifications
touch gui-canh-bao-ty-le-loi.sh && chmod +x gui-canh-bao-ty-le-loi.sh
nano gui-canh-bao-ty-le-loi.sh
```

### Gửi cảnh báo nếu tỷ lệ (failed transaction rate) trên 10% trong vòng 5 phút kèm link kibana

``` bash
#!/usr/bin/env bash
set -euo pipefail

ES_URL="https://10.1.0.13:9200"
ES_USER="elastic"
ES_PASS="DUYDUC123"
CA_CERT="/etc/apm-server/certs/http_ca.crt"

APM_INDEX="${APM_INDEX:-traces-apm*}"
SERVICE_NAME="ecommerce-backend-2"    
SERVICE_ENV="${SERVICE_ENV:-}"         

WINDOW_MIN=5                          
THRESHOLD=10                           
MIN_TOTAL=20                           

BOT_TOKEN="8326585358:AAGPImLAq7ksfXKhN-JK-40swbIPusl--R8"
CHAT_ID="4905389110"

DRY_RUN=0                              
DEBUG=1                               
COOLDOWN_SEC=300                       
STATE_FILE="/var/lib/apm-alert/state_failed_rate.json"

KIBANA_BASE="http://10.1.0.13:5601"
KIBANA_ENV="$( [[ -n "${SERVICE_ENV:-}" ]] && echo "$SERVICE_ENV" || echo "ENVIRONMENT_ALL" )"

mkdir -p "$(dirname "$STATE_FILE")"

now_iso(){ date -u -Is; }
log(){ [[ "${DEBUG:-0}" == "1" ]] && echo "[$(now_iso)] $*"; }

urlenc(){ jq -nr --arg v "$1" '$v|@uri'; }

build_kibana_overview_url() {
  local svc_enc env_enc from to
  svc_enc="$(urlenc "$SERVICE_NAME")"
  env_enc="$(urlenc "$KIBANA_ENV")"
  from="now-${WINDOW_MIN}m"
  to="now"
  echo "${KIBANA_BASE}/app/apm/services/${svc_enc}/overview?comparisonEnabled=true&environment=${env_enc}&kuery=&latencyAggregationType=avg&offset=1d&rangeFrom=$(urlenc "$from")&rangeTo=$(urlenc "$to")&serviceGroup=&transactionType=request"
}

es_post() {
  local url="$1" body="$2" body_out http
  if [[ -f "$CA_CERT" ]]; then
    body_out="$(curl -sS --show-error --cacert "$CA_CERT" \
      -u "$ES_USER:$ES_PASS" -H 'Content-Type: application/json' \
      -X POST "$url" -d "$body" -w '\n%{http_code}')"
  else
    body_out="$(curl -sS --show-error -k \
      -u "$ES_USER:$ES_PASS" -H 'Content-Type: application/json' \
      -X POST "$url" -d "$body" -w '\n%{http_code}')"
  fi
  http="${body_out##*$'\n'}"
  body_out="${body_out%$'\n'*}"
  if [[ "$http" != 2* ]]; then
    echo "ES HTTP $http" >&2
    echo "$body_out" | sed 's/^/ES-ERR: /' >&2
    return 1
  fi
  echo "$body_out"
}

send_tg() {
  local text="$1"
  if [[ "$DRY_RUN" -eq 1 ]]; then
    log "[DRY-RUN] Telegram: $text"
    return 0
  fi
  curl -sS --fail --show-error \
    -X POST "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" \
    -d "chat_id=${CHAT_ID}" \
    --data-urlencode "text=${text}" >/dev/null
}

within_cooldown() {
  [[ -f "$STATE_FILE" ]] || return 1
  local last; last="$(jq -r '.last_sent // 0' "$STATE_FILE" 2>/dev/null || echo 0)"
  local now; now="$(date +%s)"
  (( now - last < COOLDOWN_SEC ))
}
update_cooldown(){ jq -n --argjson t "$(date +%s)" '{last_sent:$t}' > "$STATE_FILE"; }

BODY=$(cat <<'JSON'
{
  "size": 0,
  "query": {
    "bool": {
      "filter": [
        {"term":{"processor.event":"transaction"}},
        {"term":{"transaction.type":"request"}},
        {"range":{"@timestamp":{"gte":"now-WM","lt":"now"}}},
        {"term":{"service.name":"SNM"}}
      ]
    }
  },
  "aggs": { "by_outcome": { "terms": { "field": "event.outcome", "size": 2 } } }
}
JSON
)
BODY="${BODY//WM/${WINDOW_MIN}m}"
BODY="${BODY//SNM/$SERVICE_NAME}"

# Thêm filter environment nếu có
if [[ -n "$SERVICE_ENV" ]]; then
  BODY="$(jq --arg env "$SERVICE_ENV" '.query.bool.filter += [ {"term":{"service.environment":$env}} ]' <<<"$BODY")"
fi

log "Query failed-rate last ${WINDOW_MIN}m, service='${SERVICE_NAME}', env='${SERVICE_ENV:-<any>}' indices='${APM_INDEX}'"
[[ "$DEBUG" -eq 1 ]] && echo "$BODY" | jq . >&2

RESP="$(es_post "${ES_URL}/${APM_INDEX}/_search" "$BODY")" || {
  echo "ERROR: Elasticsearch query failed" >&2
  exit 2
}
[[ "$DEBUG" -eq 1 ]] && echo "$RESP" | jq . | head -n 60 >&2 || true

FAIL=$(jq -r '.aggregations.by_outcome.buckets[]? | select(.key=="failure") | .doc_count' <<<"$RESP")
TOTAL=$(jq -r '[.aggregations.by_outcome.buckets[]?.doc_count] | add // 0' <<<"$RESP")
FAIL=${FAIL:-0}; TOTAL=${TOTAL:-0}
RATE=$(awk -v f="$FAIL" -v t="$TOTAL" 'BEGIN{ if(t==0){print 0}else{printf "%.2f", (f*100.0)/t} }')

log "Total=${TOTAL}, Fail=${FAIL}, Rate=${RATE}% (threshold ${THRESHOLD}%, min_total ${MIN_TOTAL})"

if (( TOTAL >= MIN_TOTAL )) && awk -v r="$RATE" -v th="$THRESHOLD" 'BEGIN{exit !(r>=th)}'; then
  if within_cooldown; then
    log "Within cooldown, skip alert."
    exit 0
  fi

  LINK="$(build_kibana_overview_url)"
  MSG=$(
    cat <<EOF
APM Failed Transaction Rate HIGH
• Service: ${SERVICE_NAME}
• Env: ${SERVICE_ENV:-n/a}
• Window: ${WINDOW_MIN}m
• Total: ${TOTAL}
• Failures: ${FAIL}
• Rate: ${RATE}% (threshold ${THRESHOLD}%)

Kibana: ${LINK}
Time: $(now_iso)
EOF
  )
  send_tg "$MSG"
  update_cooldown
  log "Alert sent."
else
  log "No alert (rate < threshold or total < MIN_TOTAL)."
fi
```

### Chạy 

``` bash
bash gui-canh-bao-ty-le-loi.sh

sudo chmod +x /etc/apm-server/notifications/gui-canh-bao-ty-le-loi.sh
sudo EDITOR=nano crontab -e
### Thêm 1 dòng vào cuối file crontab để chạy script mỗi 5 phút (ví dụ):
# chạy mỗi 5 phút, ghi log stdout/stderr vào /var/log/lay_so_log_5ph.log
SHELL=/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

*/5 * * * * /etc/apm-server/notifications/gui-canh-bao-ty-le-loi.sh
```