#  Thực nghiệm - Cài đặt Hệ thống Giám sát và Thu thập dữ liệu

``` arduino
monitoring/
├─ docker-compose.yml
├─ prometheus/
│  ├─ prometheus.yml
│  └─ alert-rules.yml
├─ alertmanager/
│  └─ alertmanager.yml
├─ grafana/
│  ├─ provisioning/
│  │  ├─ datasources.yaml
│  │  └─ dashboards.yaml
│  ├─ dashboards/    # folder chứa dashboard JSON/YAML nếu có
│  └─ .grafana.secret
```

## 1. docker-compose

``` yaml
version: "3.8"

services:
  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    restart: unless-stopped
    volumes:
      - ./prometheus/prometheus.yml:/etc/prometheus/prometheus.yml:ro
      - ./prometheus/alert-rules.yml:/etc/prometheus/alert-rules.yml:ro
      - prometheus_data:/prometheus
    ports:
      - "9090:9090"
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--storage.tsdb.retention.time=15d'
      - '--web.console.libraries=/usr/share/prometheus/console_libraries'
      - '--web.console.templates=/usr/share/prometheus/consoles'
    networks:
      - monitoring

  alertmanager:
    image: prom/alertmanager:latest
    container_name: alertmanager
    restart: unless-stopped
    volumes:
      - ./alertmanager/alertmanager.yml:/etc/alertmanager/alertmanager.yml:ro
      - alertmanager_data:/alertmanager
    ports:
      - "9093:9093"
    command:
      - '--config.file=/etc/alertmanager/alertmanager.yml'
      - '--storage.path=/alertmanager'
    networks:
      - monitoring

  grafana:
    image: grafana/grafana:latest
    container_name: grafana
    restart: unless-stopped
    env_file:
      - ./grafana/.grafana.secret
    volumes:
      - grafana_data:/var/lib/grafana
      - ./grafana/provisioning:/etc/grafana/provisioning:ro
      - ./grafana/dashboards:/var/lib/grafana/dashboards:ro
    ports:
      - "3000:3000"
    networks:
      - monitoring

  blackbox-exporter:
    image: prom/blackbox-exporter:latest
    container_name: blackbox_exporter
    restart: unless-stopped
    ports:
      - "9115:9115"
    networks:
      - monitoring

  snmp-exporter:
    image: prom/snmp-exporter:latest
    container_name: snmp_exporter
    restart: unless-stopped
    ports:
      - "9116:9116"
    networks:
      - monitoring

volumes:
  prometheus_data:
  alertmanager_data:
  grafana_data:

networks:
  monitoring:
    driver: bridge

```

## 2. prometheus/prometheus.yml

``` yaml
global:
  scrape_interval: 15s
  evaluation_interval: 15s
  scrape_timeout: 10s

alerting:
  alertmanagers:
    - static_configs:
        - targets:
            - "alertmanager:9093"   # service name trong docker network

rule_files:
  - "/etc/prometheus/alert-rules.yml"

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['prometheus:9090']

  - job_name: 'node_exporter'
    static_configs:
      - targets: ['host.docker.internal:9100'] # thay bằng IP:9100 của node exporter hoặc tên host
        labels:
          role: 'node'

  - job_name: 'blackbox'
    metrics_path: /probe
    params:
      module: [http_2xx]
    static_configs:
      - targets:
          - http://example.com
    relabel_configs:
      - source_labels: [__address__]
        target_label: __param_target
      - source_labels: [__param_target]
        target_label: instance
      - target_label: __address__
        replacement: blackbox_exporter:9115

  - job_name: 'snmp'
    static_configs:
      - targets: ['192.168.1.1']  # ví dụ device SNMP
    metrics_path: /snmp
    relabel_configs: []
```

## 3. prometheus/alert-rules.yml

``` yaml
groups:
  - name: linux_alerts
    rules:
      - alert: InstanceDown
        expr: up == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Instance {{ $labels.instance }} down"
          description: "{{ $labels.instance }} of job {{ $labels.job }} has been down for more than 1 minute."

  - name: cpu_alerts
    rules:
      - alert: HighCPUUsage
        expr: 100 - (avg by (instance)(irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 85
        for: 2m
        labels:
          severity: warning
        annotations:
          summary: "High CPU on {{ $labels.instance }}"
          description: "CPU usage is above 85% for more than 2 minutes."

```

## 4. alertmanager/alertmanager.yml

``` yaml
global:
  resolve_timeout: 5m

route:
  group_by: ['alertname', 'job', 'instance']
  group_wait: 10s
  group_interval: 10s
  repeat_interval: 1h
  receiver: "email"

receivers:
  - name: "email"
    email_configs:
      - to: "you@example.com"
        from: "you@example.com"
        smarthost: "smtp.gmail.com:587"
        auth_identity: "you@example.com"
        auth_username: "you@example.com"
        # auth_secret: "app-password"  # đặt secret trong môi trường thực tế

inhibit_rules:
  - source_match:
      severity: 'critical'
    target_match:
      severity: 'warning'
    equal: ['instance', 'job']

```

## 5. Grafana provisioning

1. grafana/provisioning/datasources.yaml

``` yaml
apiVersion: 1
datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus:9090
    isDefault: true
    editable: false
  - name: Alertmanager
    type: alertmanager
    access: proxy
    url: http://alertmanager:9093
    jsonData:
      implementation: prometheus
      handleGrafanaManagedAlerts: false
```

2. grafana/provisioning/dashboards.yaml

``` yaml
apiVersion: 1
providers:
  - name: 'Default'
    orgId: 1
    folder: ''
    type: file
    disableDeletion: false
    updateIntervalSeconds: 60
    options:
      path: /var/lib/grafana/dashboards
```

3. grafana/.grafana.secret

``` yaml
GF_SECURITY_ADMIN_USER=admin
GF_SECURITY_ADMIN_PASSWORD=admin
```

## 6. Cách chạy

``` bash
docker compose up -d

docker compose ps
docker logs prometheus
docker logs alertmanager
docker logs grafana
```

- Prometheus: http://<host>:9090

- Alertmanager: http://<host>:9093

- Grafana: http://<host>:3000 (admin/admin)