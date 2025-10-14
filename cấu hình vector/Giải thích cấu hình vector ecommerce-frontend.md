—
data_dir: /var/lib/vector
• Thư mục Vector dùng để lưu state (checkpoint đọc docker logs, offset, cache…).

—
sources:
fe_docker:
type: docker_logs
• Định nghĩa một source đọc log trực tiếp từ Docker Engine.

```
docker_host: "unix:///var/run/docker.sock"  
```

• Kết nối tới Docker daemon qua UNIX socket mặc định.

```
include_containers:  
  - "ecommerce-fe"  
```

• Chỉ thu log từ container tên `ecommerce-fe` (lọc container-level ngay tại source).

—
transforms:
• Khối các bước biến đổi log sau khi đọc.

fe_enrich_env:
type: remap
inputs: [fe_docker]
• Transform VRL; input là các sự kiện từ `fe_docker`.

```
source: |  
  .message = to_string!(.message)  
```

• Ép `.message` thành chuỗi chắc chắn (tránh bytes/object).

```
  if !exists(.labels) { .labels = {} }  
```

• Đảm bảo tồn tại object `.labels`.

```
  .labels.env = "prod"  
```

• Gắn nhãn môi trường là `prod`.

```
  if !exists(.service) { .service = {} }  
```

• Đảm bảo tồn tại object `.service`.

```
  .service.name = "ecommerce-frontend"  
```

• Đặt tên service cố định để truy vấn/visualize theo service.

```
  if !exists(.container) { .container = {} }  
```

• Đảm bảo tồn tại object `.container`.

```
  if exists(.container_name) { .container.name = to_string!(.container_name) }  
```

• Nếu có trường `container_name` từ source docker => đưa vào `.container.name`.

```
  if exists(.image) { .container.image = to_string!(.image) }  
```

• Nếu có trường `image` => đưa vào `.container.image`.

—
fe_parse_nginx:
type: remap
inputs: [fe_enrich_env]
• Bước parse nội dung log Nginx (entrypoint/error/access/misc) sau enrich.

```
source: |  
  msg = to_string!(.message)  
```

• Tạo biến `msg` (string) để dùng trong regex/điều kiện.

```
  if starts_with(msg, "/docker-entrypoint.sh:") || contains(msg, "/docker-entrypoint.d/") {  
```

• Nhánh 1: log từ script entrypoint của image Nginx.

```
    if !exists(.event) { .event = {} }  
    .event.dataset = "nginx.entrypoint"  
```

• Gắn dataset riêng cho log khởi tạo container.

```
    if !exists(.log) { .log = {} }  
    .log.level = "info"  
```

• Đặt mức log là `info` cho nhóm entrypoint.

```
  } else {  
```

• Không phải entrypoint => thử parse theo error log trước.

```
    m1, e1 = parse_regex(  
      msg,  
      r'^(?P<ts>\d{4}/\d{2}/\d{2}\s\d{2}:\d{2}:\d{2})\s+\[(?P<lvl>[a-z]+)\]\s+(?P<pid>\d+)#(?P<tid>\d+):\s*(?P<err>.*)$'  
    )  
```

• Regex Nginx error: `YYYY/MM/DD HH:MM:SS [level] pid#tid: message`.

```
    if e1 == null {  
```

• Parse error log thành công.

```
      .timestamp = parse_timestamp!(m1.ts, format: "%Y/%m/%d %H:%M:%S")  
```

• Đặt `.timestamp` theo time trong log error (không có timezone).

```
      if !exists(.log) { .log = {} }  
      .log.level = to_string(m1.lvl)  
```

• Lưu level (error/warn/notice…) vào `.log.level`.

```
      if !exists(.process) { .process = {} }  
      .process.pid = to_int!(m1.pid)  
```

• Gắn PID process Nginx.

```
      if !exists(.thread) { .thread = {} }  
      .thread.id = to_int!(m1.tid)  
```

• Gắn thread id (TID) theo format `pid#tid`.

```
      .message = m1.err  
```

• Ghi đè `.message` bằng phần lỗi đã tách.

```
      if !exists(.event) { .event = {} }  
      .event.dataset = "nginx.error"  
```

• Đặt dataset là error.

```
    } else {  
```

• Không phải error => thử parse access log.

```
      m2, e2 = parse_regex(  
        msg,  
        r'^(?P<remote_addr>\S+)\s+\S+\s+\S+\s+\[(?P<time>[^\]]+)\]\s+"(?P<method>\S+)\s+(?P<path>\S+)\s+(?P<protocol>[^"]+)"\s+(?P<status>\d{3})\s+(?P<body_bytes>\d+)\s+"(?P<referrer>[^"]*)"\s+"(?P<ua>[^"]*)"'  
      )  
```

• Regex Nginx access “chuẩn” có trường: IP, time, method, path, protocol, status, bytes, referrer, user-agent.
(Giả định log\_format tương thích; nếu bạn tùy biến cần chỉnh regex).

```
      if e2 == null {  
```

• Parse access thành công.

```
        .timestamp = parse_timestamp!(m2.time, format: "%d/%b/%Y:%H:%M:%S %z")  
```

• Parse time theo format `10/Mar/2025:12:34:56 +0700`.

```
        if !exists(.event) { .event = {} }  
        .event.dataset = "nginx.access"  
```

• Đặt dataset = access.

```
        if !exists(.client) { .client = {} }  
        .client.ip = m2.remote_addr  
```

• Gắn IP client.

```
        if !exists(.http) { .http = {} }  
        if !exists(.http.request) { .http.request = {} }  
        .http.request.method = m2.method  
        .http.request.referrer = m2.referrer  
```

• Gắn method và referrer vào nhánh http.request.

```
        if !exists(.url) { .url = {} }  
        .url.path = m2.path  
```

• Gắn path (URI) vào `.url.path`.

```
        if !exists(.network) { .network = {} }  
        .network.protocol = m2.protocol  
```

• Lưu giao thức (HTTP/1.1, HTTP/2…).

```
        if !exists(.http.response) { .http.response = {} }  
        .http.response.status_code = to_int!(m2.status)  
        if !exists(.http.response.body) { .http.response.body = {} }  
        .http.response.body.bytes = to_int!(m2.body_bytes)  
```

• Mã trạng thái + số byte trả về.

```
        if !exists(.user_agent) { .user_agent = {} }  
        .user_agent.original = m2.ua  
```

• Lưu User-Agent gốc để có thể parse UA sau này.

```
      } else {  
```

• Không match entrypoint/error/access => rơi vào nhóm khác.

```
        if !exists(.event) { .event = {} }  
        .event.dataset = "nginx.misc"  
```

• Đặt dataset = misc (dạng log khác).

```
      }  
    }  
  }  
```

—
fe_pii_mask:
type: remap
inputs: [fe_parse_nginx]
• Mask dữ liệu nhạy cảm trong message/referrer/UA.

```
source: |  
  if exists(.message) {  
    .message = to_string(.message) ?? ""  
    .message = replace(.message, r'([A-Za-z0-9._%+\-])([A-Za-z0-9._%+\-]*?)@([A-Za-z0-9.\-]+\.[A-Za-z]{2,})', "$$1***@$$3")  
```

• Ẩn email: giữ ký tự đầu, thay phần local còn lại bằng `***`, giữ nguyên domain.

```
    .message = replace(.message, r'\b(\d{4})\d{8,11}(\d{4})\b', "$$1********$$2")  
```

• Ẩn số thẻ 13–19 chữ số: giữ 4 đầu/cuối, thay giữa bằng `********`.

```
    .message = replace(.message, r'(?i)(authorization:?\s*bearer\s+)[A-Za-z0-9\-\._]+', "$$1******")  
```

• Ẩn bearer token trong header Authorization.

```
    .message = replace(.message, r'(?i)(api[_\-]?key|token|secret)["\s=:]*[A-Za-z0-9\-\._]{6,}', "$$1=******")  
```

• Ẩn các chuỗi có vẻ là apiKey/token/secret.

```
  }  
  if exists(.http) && exists(.http.request) && exists(.http.request.referrer) {  
    .http.request.referrer = to_string(.http.request.referrer) ?? ""  
    .http.request.referrer = replace(.http.request.referrer, r'([A-Za-z0-9._%+\-])([A-Za-z0-9._%+\-]*?)@([A-Za-z0-9.\-]+\.[A-Za-z]{2,})', "$$1***@$$3")  
```

• Ẩn email trong referrer nếu có.

```
  }  
  if exists(.user_agent) && exists(.user_agent.original) {  
    .user_agent.original = to_string(.user_agent.original) ?? ""  
    .user_agent.original = replace(.user_agent.original, r'\b(\d{4})\d{8,11}(\d{4})\b', "$$1********$$2")  
```

• Ẩn dãy số kiểu thẻ trong UA (đề phòng case nhạy cảm chui vào UA).

```
  }  
```

—
fe_filter_debug_prod:
type: filter
inputs: [fe_pii_mask]
condition: '!(.labels.env == "prod" && .log.level == "debug")'
• Bộ lọc: loại bỏ log có `.labels.env == "prod"` **và** `.log.level == "debug"`.
• Cú pháp phủ định `!()` giữ lại mọi thứ trừ điều kiện trên.

—
fe_route:
type: route
inputs: [fe_filter_debug_prod]
• Phân nhánh theo dataset sau khi mask & filter.

```
route:  
  to_access:      '.event.dataset == "nginx.access"'  
  to_error:       '.event.dataset == "nginx.error"'  
  to_entrypoint:  '.event.dataset == "nginx.entrypoint"'  
  to_misc:        '.event.dataset == "nginx.misc"'  
```

• 4 nhánh rõ ràng; sự kiện không khớp rơi vào `_unmatched`.

—
sinks:
• Điểm đẩy log ra ngoài.

es_fe_access:
type: elasticsearch
inputs: [fe_route.to_access]
• Gửi access logs sang Elasticsearch.

```
endpoints: ["https://192.168.157.10:9200"]  
```

• Endpoint ES qua HTTPS.

```
auth: { strategy: basic, user: elastic, password: "KHFDPeU6" }  
```

• Basic auth; (khuyến nghị: dùng biến môi trường/secret, không hard-code).

```
tls:  { ca_file: "/etc/vector/certs/http_ca.crt" }  
```

• Tin cậy CA tự ký của cluster ES.

```
bulk: { index: "ecommerce-frontend-nginx-access-%Y-%m-%d" }  
```

• Ghi theo index ngày cho access (pattern `%Y-%m-%d` lấy theo `.timestamp`).

—
es_fe_error:
type: elasticsearch
inputs: [fe_route.to_error]
endpoints/auth/tls như trên
bulk: { index: "ecommerce-frontend-nginx-service-%Y-%m-%d" }
• Gửi error logs vào index `...nginx-service-YYYY-MM-DD` (tên index theo bạn đã đặt; nếu muốn “error” rõ nghĩa hơn thì có thể đổi).

—
es_fe_entrypoint:
type: elasticsearch
inputs: [fe_route.to_entrypoint]
endpoints/auth/tls như trên
bulk: { index: "ecommerce-frontend-nginx-init-%Y-%m-%d" }
• Log khởi tạo container (entrypoint) đi vào index `...nginx-init-YYYY-MM-DD`.

—
es_fe_misc:
type: elasticsearch
inputs: [fe_route.to_misc]
endpoints/auth/tls như trên
bulk: { index: "ecommerce-frontend-nginx-misc-%Y-%m-%d" }
• Log không khớp các định dạng chính => index `...nginx-misc-YYYY-MM-DD`.

—
stdout_fe_debug:
type: console
inputs:
- fe_route.to_access
- fe_route.to_error
- fe_route.to_entrypoint
- fe_route.to_misc
• In tất cả nhánh chuẩn ra stdout (hữu ích khi debug pipeline).

```
target: stdout  
```

• Đích xuất là STDOUT.

```
encoding:  
  codec: json  
```

• In theo JSON (dễ đọc & tái parse).

—
blackhole_fe_unmatched:
type: blackhole
inputs: [fe_route._unmatched]
• **Discard** (bỏ) mọi sự kiện không khớp route nào (nhánh `_unmatched`) để tránh rác trôi sang ES hoặc stdout.

—
Tóm tắt luồng
docker_logs(ecommerce-fe) => enrich_env => parse_nginx(entrypoint/error/access/misc) => pii_mask => filter_debug_prod => route(to_access|to_error|to_entrypoint|to_misc|_unmatched) => sinks(ES per-index + console) / blackhole (drop unmatched).