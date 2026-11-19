SRE Observability Platform
A Kubernetes-based observability platform demonstrating practical Site Reliability Engineering concepts using Terraform, Prometheus, Grafana, Alertmanager, OpenTelemetry, Docker, and Kubernetes.

The project deploys a containerized application, exposes application metrics, collects them with Prometheus, visualizes system behavior in Grafana, and generates alerts when predefined reliability conditions are violated.

Architecture
The platform consists of:

Flask application exposing Prometheus metrics
Kubernetes for container orchestration
Terraform for infrastructure configuration
Helm for deploying observability components
Prometheus for metrics collection and alert evaluation
Grafana for metrics visualization
Alertmanager for alert management
OpenTelemetry Collector for telemetry processing
Architecture Flow
                         Kubernetes Cluster
                                 |
             +-------------------+-------------------+
             |                   |                   |
        sre-project          monitoring            metrics
             |                   |                   |
       Flask App          Prometheus Server     OpenTelemetry
             |                   |               Collector
             | /metrics          |
             +------------------>|
                                 |
                          Alert Rules
                           /       \
                          /         \
                     Grafana     Alertmanager
                        |             |
                   Dashboards      Alerts

Prerequisites

Install:

Docker
Kubernetes
kubectl
Terraform
Helm
Git

