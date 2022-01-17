# monitoring-stack
A set of the following monitoring tools.

#### prometheus
- `Kubernetes kind:` **StatefulSet**
- `Image:` **quay.io/prometheus/prometheus**
- `App version:` **v2.31.1**

#### alertmanager
- `Kubernetes kind:` **StatefulSet**
- `Image:` **quay.io/prometheus/alertmanager**
- `App version:` **v0.23.0**

#### node-exporter
- `Kubernetes kind:` **Daemonset**
- `Image:` **quay.io/prometheus/node-exporter**
- `App version:` **v1.3.0**

#### pushgateway
- `Kubernetes kind:` **Deployment**
- `Image:` **prom/pushgateway**
- `App version:` **v1.4.2**

#### kube-state-metrics
- `Kubernetes kind:` **Deployment**
- `Image:` **k8s.gcr.io/kube-state-metrics/kube-state-metrics**
- `App version:` **v1.9.8**

#### netdata
- `Kubernetes kind:` **Daemonset**
- `Image:` **netdata/netdata**
- `App version:` **v1.31.0**

#### filebeat
- `Kubernetes kind:` **Daemonset**
- `Image:` **docker.elastic.co/beats/filebeat**
- `App version:` **7.16.2**

#### promtail
- `Kubernetes kind:` **Daemonset**
- `Image:` **grafana/promtail**
- `App version:` **2.3.0**

The rest of the details are visible in the `values.yaml` file.
