data_dir: /var/lib/vector
• Thư mục Vector dùng để lưu state nội bộ (checkpoint đọc file, bookmark offset…). Đổi thư mục này khi bạn muốn tách dữ liệu vận hành Vector khỏi hệ thống.

—
sources:
java_file:
type: file
• Định nghĩa một “nguồn” đọc log từ file.

```
include:  
  - /var/log/java/ecom-backend.log  
```

• Danh sách đường dẫn file cần tail.

```
ignore_older_secs: 0  
```

• Không bỏ qua file cũ (0 = luôn đọc, kể cả file cũ).

```
multiline:  
```

• Bật gom log nhiều dòng thành một sự kiện (stacktrace, SQL dài…).

```
  start_pattern: '^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}[+-]\d{2}:\d{2}\s'  
```

• Regex nhận biết “dòng bắt đầu” của một log mới: timestamp RFC3339 có offset ±HH\:MM và có dấu cách sau đó.
Lưu ý: dạng `...Z` (UTC “Z”) sẽ **không khớp** regex này. Nếu log của bạn là `2025-08-13T17:36:28.872Z INFO ...` thì nên sửa thành:
`^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}(?:Z|[+-]\d{2}:\d{2})\s`

```
  condition_pattern: '^(?:\s|at\s|Caused by:|Hibernate:)'  
```

• Dòng “tiếp diễn”: bắt đầu bằng khoảng trắng, hoặc “at ” (stacktrace), hoặc “Caused by:”, hoặc “Hibernate:”. Các dòng này được dán vào log đã bắt đầu ở trên.

```
  mode: continue_through  
```

• Chế độ gom: các dòng khớp `condition_pattern` sẽ được nối tiếp **cho đến** khi gặp dòng không khớp nữa (giữ mạch stacktrace/SQL).

```
  timeout_ms: 2000  
```

• Nếu trong 2 giây không thấy thêm dòng tiếp diễn, Vector sẽ chốt sự kiện hiện tại để đẩy đi.

—
transforms:
• Chuỗi các bước xử lý/biến đổi sự kiện sau khi đọc.

enrich_env:
type: remap
inputs: [java_file]
• Transform VRL, nhận input từ source `java_file`.

```
source: |  
  .message = to_string!(.message)  
```

• Ép `.message` thành chuỗi (nếu trước đó là bytes/object).

```
  if !exists(.labels) { .labels = {} }  
```

• Đảm bảo có object `.labels`.

```
  .labels.env = "prod"  
```

• Gắn nhãn môi trường là “prod”. (Có thể đổi lấy từ env var cho linh hoạt.)

```
  .input = { "type": "file", "path": "/var/log/java/ecom-backend.log" }  
```

• Thêm metadata tự viết: nguồn là file nào.

—
parse_spring:
type: remap
inputs: [enrich_env]
• Bước parse chính cho format Spring Boot.

```
source: |  
  m, err = parse_regex(  
    .message,  
    r'^(?P<ts>\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}[+-]\d{2}:\d{2})\s+(?P<level>[A-Z]+)\s+(?P<pid>\d+)\s+---\s+\[(?P<app>[^\]]+)\]\s+\[(?P<thr>[^\]]+)\]\s+(?P<logger>[^:]+?)\s*:\s*(?P<msg>.*)$'  
  )  
```

• Dùng regex có nhóm đặt tên để tách:

* `ts`: timestamp (RFC3339 **chỉ** offset ±HH\:MM; **không** nhận `Z`)
* `level`: cấp log (INFO/WARN/ERROR/…)
* `pid`: process id
* `app`: nội dung trong `[...]` đầu tiên (ví dụ tên app hay context)
* `thr`: thread name (trong `[...]` thứ hai)
* `logger`: class logger (com.x.y.Class)
* `msg`: phần message sau dấu `:`
  Khuyến nghị: như đã nói ở trên, nếu log là `Z` thì sửa cả regex này thành `...(?P<ts>...(?:Z|[+-]\d{2}:\d{2}))...`.

  if err == null {
  • Nếu parse thành công:

  ```
  .timestamp = parse_timestamp!(m.ts, format: "%+")  
  ```

• Chuyển `m.ts` sang trường thời gian chuẩn của Vector. `"%+"` là RFC3339 (nhận cả offset; cũng nhận `Z` nếu bạn sửa regex ở trên cho bắt `Z`).

```
    if !exists(.log) { .log = {} }  
    .log.level = downcase!(m.level)  
```

• Tạo `.log.level` (lowercase: info, warn…).

```
    if !exists(.process) { .process = {} }  
    .process.pid = to_int!(m.pid)  
```

• Lưu PID vào `.process.pid`.

```
    .labels.app = m.app  
```

• Gán nhãn app (từ `[...]`).

```
    if !exists(.thread) { .thread = {} }  
    .thread.name = m.thr  
```

• Lưu thread name vào `.thread.name`. (Nếu theo ECS, cân nhắc dùng `process.thread.name`.)

```
    .logger = m.logger  
```

• Gán tên logger (class).

```
    .message = m.msg  
```

• Ghi đè message bằng phần sau dấu `:` (đã loại bỏ header).

```
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
```

• Phân loại dataset theo prefix logger: Hibernate => `spring.hibernate`; Spring/Tomcat/Apache => `spring.framework`; còn lại => `spring.app`.

```
  } else {  
```

• Nếu **không parse được** theo regex trên:

```
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
```

• Trường hợp message bắt đầu bằng `Hibernate: ` thì coi như log SQL của Hibernate => đặt `event.dataset = hibernate.sql`, cấp `info`, và trích phần query vào `.sql.query`.
• Còn lại xếp vào `spring.continuation` (phần tiếp diễn của một log chính — nhỡ regex không match).

```
  p, perr = parse_regex(.message, r'Tomcat initialized with port (?P<port>\d+)')  
  if perr == null {  
    if !exists(.http) { .http = {} }  
    if !exists(.http.server) { .http.server = {} }  
    .http.server.port = to_int!(p.port)  
  }  
```

• Bắt riêng thông tin port Tomcat nếu dòng message có pattern này => lưu vào `.http.server.port`.

—
trace\_and\_context:
type: remap
inputs: \[parse\_spring]

```
source: |  
  t, terr = parse_regex(.message, r'(?:^|[\s,])trace_id=(?P<trace>[A-Za-z0-9\-_]+)')  
  if !exists(.trace) { .trace = {} }  
  if terr == null { .trace.id = t.trace } else { .trace.id = uuid_v4() }  
```

• Tìm `trace_id=...` trong message. Nếu thấy => `.trace.id` = giá trị bắt được; nếu không => sinh `uuid_v4()` để luôn có trace id phục vụ truy vết.

```
  if !exists(.service) { .service = {} }  
  app_s = "unknown-service"  
  if exists(.labels) && exists(.labels.app) { app_s = to_string!(.labels.app) }  
```

• Lấy tên service mặc định từ `.labels.app`, nếu không có thì “unknown-service”.

```
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
```

• Suy luận `service.name` từ tên logger (lấy segment thứ 3, ví dụ `com.cart.ecom_proj.EcomProjApplication` => `ecom_proj`). Nếu không đủ segment hoặc không có dấu chấm => fallback `app_s`.

—
pii\_mask:
type: remap
inputs: \[trace\_and\_context]

```
source: |  
  if exists(.message) {  
    .message = to_string!(.message)  
    # Email => user***@domain  
    .message = replace(.message, r'([A-Za-z0-9._%+\-])([A-Za-z0-9._%+\-]*?)@([A-Za-z0-9.\-]+\.[A-Za-z]{2,})', "$$1***@$$3")  
    # Thẻ 13–19 digits => 1234********5678  
    .message = replace(.message, r'\b(\d{4})\d{8,11}(\d{4})\b', "$$1********$$2")  
    # Bearer token  
    .message = replace(.message, r'(?i)(authorization:?\s*bearer\s+)[A-Za-z0-9\-\._]+', "$$1******")  
    # apiKey/token/secret  
    .message = replace(.message, r'(?i)(api[_\-]?key|token|secret)["\s=:]*[A-Za-z0-9\-\._]{6,}', "$$1=******")  
  }  
```

• Ẩn PII: email, số thẻ (13–19 số), bearer token, và các khóa nhạy cảm.
Lưu ý: tùy phiên bản Vector/VRL, trong chuỗi thay thế có thể dùng `$1`/`${name}`. Nếu bạn thấy kết quả ra **chữ `$1` nguyên xi** thì hãy bỏ bớt một dấu `$` trong replacement (tức dùng `$1***@$3`, `$1********$2`, …).

```
  if exists(.sql) && exists(.sql.query) {  
    .sql.query = to_string!(.sql.query)  
    .sql.query = replace(.sql.query, r'\b(\d{4})\d{8,11}(\d{4})\b', "$$1********$$2")  
  }  
```

• Ẩn số thẻ trong phần truy vấn SQL (nếu có).

—
filter\_debug\_prod:
type: filter
inputs: \[pii\_mask]
condition: '!(.labels.env == "prod" && .log.level == "debug")'
• Bộ lọc: **loại** các log debug ở môi trường prod. Điều kiện viết dưới dạng phủ định `!()` nên kết quả là “giữ lại” mọi thứ **trừ** (prod & debug). Nếu `.log.level` không tồn tại thì vế so sánh sẽ false => log vẫn đi qua (hợp lý).

—
route\_by\_dataset:
type: route
inputs: \[filter\_debug\_prod]
route:
to\_app: '.event.dataset == "spring.app"'
to\_framework: '.event.dataset == "spring.framework"'
to\_hibernate: '.event.dataset == "hibernate.sql" || .event.dataset == "spring.hibernate"'
to\_misc: '.event.dataset == "spring.continuation"'
• Phân luồng sự kiện sang 4 “nhánh” theo `event.dataset`. Các sự kiện không khớp rơi vào `_unmatched`.

—
sinks:
• Điểm đích xuất log.

es\_app:
type: elasticsearch
inputs: \[route\_by\_dataset.to\_app]
• Sink ES cho nhánh “app”.

```
endpoints: ["https://192.168.157.10:9200"]  
```

• URL ES (HTTPS qua IP).

```
auth:  
  strategy: basic  
  user: elastic  
  password: "KHFDPeU6"  
```

• Xác thực basic. (Nên đặt bằng biến môi trường và hạn quyền user này.)

```
tls:  
  ca_file: "/etc/vector/certs/http_ca.crt"  
```

• Tin cậy CA tự ký của ES.

```
bulk:  
  index: "ecommerce-backend-app-%Y-%m-%d"  
```

• Ghi bulk theo index pattern ngày (ví dụ `ecommerce-backend-app-2025-09-23`). Vector sẽ format từ `.timestamp`.

—
es\_framework:
type: elasticsearch
inputs: \[route\_by\_dataset.to\_framework]
endpoints: \["[https://192.168.157.10:9200](https://192.168.157.10:9200)"]
auth: { basic… }
tls: { ca\_file… }
bulk:
index: "ecommerce-backend-framework-%Y-%m-%d"
• Sink ES cho log framework (Spring/Tomcat/Apache).

—
es\_hibernate:
type: elasticsearch
inputs: \[route\_by\_dataset.to\_hibernate]
endpoints/auth/tls như trên
bulk:
index: "ecommerce-backend-hibernate-%Y-%m-%d"
• Sink ES cho log Hibernate/SQL.

—
es\_misc:
type: elasticsearch
inputs: \[route\_by\_dataset.to\_misc]
endpoints/auth/tls như trên
bulk:
index: "ecommerce-backend-misc-%Y-%m-%d"
• Sink ES cho phần “continuation/khác”.

—
blackhole\_unmatched:
type: blackhole
inputs: \[route\_by\_dataset.\_unmatched]
• Nuốt mọi sự kiện không khớp route (tránh trôi rác).

—
stdout\_debug:
type: console
inputs:
\- route\_by\_dataset.to\_app
\- route\_by\_dataset.to\_framework
\- route\_by\_dataset.to\_hibernate
\- route\_by\_dataset.to\_misc
• In song song ra stdout các nhánh chính (tiện debug pipeline).

```
target: stdout  
```

• Đích là stdout (mặc định).

```
encoding:  
  codec: json  
```

• Xuất JSON (dễ đọc/parse).

—
Tóm tắt luồng xử lý
file => gom multiline => enrich_env (gắn env/provenance) => parse_spring (tách trường, phân dataset) => trace_and_context (trace id, service name) => pii_mask (ẩn nhạy cảm) => filter_debug_prod (bỏ debug@prod) => route_by_dataset => đẩy về 4 index ES riêng (app/framework/hibernate/misc) + in console (debug) + drop unmatched logs.