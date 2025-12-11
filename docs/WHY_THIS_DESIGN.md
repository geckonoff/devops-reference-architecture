# Why This Architecture?

### 🔐 Security-First Choices
- **NetworkPolicy** for `example-comment` → only `example-ui` can access it  
- **Non-root containers** (UID 1000+)  
- **Secrets via K8s Secrets** (not env vars in manifests)

### 📈 Scalability Decisions
- **StatefulSet for MongoDB** → stable network IDs, ordered updates  
- **HorizontalPodAutoscaler** (in `values.yaml`) → scale on CPU/memory  
- **StorageClass: fast** → SSD-backed volumes for DBs

### 🛠️ Operational Excellence
- **Grafana dashboards** grouped by SLO:  
  - `UI_Service_Monitoring.json` — latency, error rate  
  - `DockerMonitoring.json` — container health  
- **Fluentd buffering** → no log loss during ES downtime  
- **Terraform remote state** (example in `backend.tf.example`) → team-safe

### 💡 DevOps Lessons Learned
- Avoid `hostPort` — use `NodePort` + LB instead  
- Always version Helm charts (`Chart.yaml: version: 1.1.0`)  
- Never commit `.tfstate` — use `terraform { backend "s3" }`  