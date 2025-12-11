# 🏗️ DevOps Reference Architecture  
### by Aleksei Shibanov — Production-Ready Infrastructure Blueprint  

> 🔍 This repo demonstrates a **battle-tested infrastructure stack** for scalable web applications — suitable for startups, SaaS, or internal tools.  
> ✅ All components are modular, documented, and designed for reuse.

---

## 🌐 Architecture Overview  
![High-Level Diagram](docs/architecture.png) *(optional: добавьте позже через draw.io)*

- **Application Layer**: Ruby/Python microservices (`example-ui`, `example-comment`, `example-post`)  
- **Data Layer**: MongoDB (stateful), Redis (caching)  
- **Orchestration**: Kubernetes (manual manifests + Helm charts)  
- **IaC**: Terraform (cloud provisioning), Packer (AMI/image), Ansible (configuration)  
- **Observability**: Prometheus + Grafana (metrics), EFK (logs), Blackbox (health checks)  
- **CI/CD**: GitLab CI examples (build → test → deploy)  

---

## 📂 Key Directories  

| Path | Purpose | Why It Matters |
|------|---------|----------------|
| `terraform/` | Cloud provisioning (tested on Hetzner, AWS-compatible) | **Idempotent infrastructure** — server, network, storage in 5 min |
| `ansible/` | Configuration management (Postfix-ready: variables for `mail_domain`, `ldap_base`) | Shows **separation of config & secrets**, role-based design |
| `kubernetes/reddit/` → `kubernetes/example-app/` | K8s manifests (Deployments, Services, Ingress, NetworkPolicy) | Real-world **security hardening** (policies, non-root containers) |
| `kubernetes/Charts/` | Helm charts (modular, values-driven) | Demonstrates **reusability** — deploy same app to dev/stage/prod |
| `monitoring/` | Prometheus alerts, Grafana dashboards | **SLO/SLI-ready**: latency, error rate, saturation (USE method) |
| `logging/efk/` | Fluentd → Elasticsearch pipeline | Logs as a **first-class citizen**, not afterthought |

---

## 🛠️ How to Use This  
1. **As a template**: `cp -r terraform/ my-project/ && terraform init`  
2. **As a learning resource**: See how TLS, storage, and networking are configured  
3. **As proof of expertise**: Every component reflects production best practices  

> 💡 **Customization guide**: Replace `example-*` with your service names. All domain/cred values are in `*.tfvars.example` and `values.yaml` — no hardcoded secrets.

---

## ⚠️ Disclaimer  
This is a **generalized reference implementation**.  
- All domains (`example.com`), IPs, and credentials are placeholders.  
- Real deployments require security review, backup strategy, and compliance checks.  
- Sensitive client configurations are not included.

© Aleksei Shibanov — Freelance DevOps Engineer | [ag.shibanov@gmail.com](ag.shibanov@gmail.com)