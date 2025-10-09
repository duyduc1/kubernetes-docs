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

### Tưu duy thiết kế hệ thống Logging