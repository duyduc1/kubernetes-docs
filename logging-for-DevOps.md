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