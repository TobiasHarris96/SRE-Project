resource "helm_release" "prometheus" {
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus"

  namespace = kubernetes_namespace_v1.monitoring.metadata[0].name

  values = [
    yamlencode({

      # ==========================================
      # Prometheus Alert Rules
      # ==========================================
      serverFiles = {
        "alerting_rules.yml" = {
          groups = [
            {
              name = "sre-demo-app-alerts"

              rules = [

                # Critical alert when the application target
                # disappears or Prometheus cannot scrape it.
                {
                  alert = "SREDemoAppDown"

                  expr = "absent(up{service=\"sre-demo-service\"}) or up{service=\"sre-demo-service\"} == 0"

                  for = "1m"

                  labels = {
                    severity = "critical"
                  }

                  annotations = {
                    summary     = "SRE Demo App is down"
                    description = "Prometheus cannot scrape the SRE Demo application."
                  }
                },

                # Warning when application errors are detected.
                {
                  alert = "SREDemoAppErrors"

                  expr = "sum(rate(app_errors_total[5m])) > 0"

                  for = "1m"

                  labels = {
                    severity = "warning"
                  }

                  annotations = {
                    summary     = "SRE Demo App is producing errors"
                    description = "Application errors have been detected."
                  }
                },

                # Warning when P95 latency exceeds one second.
                {
                  alert = "SREDemoAppHighLatency"

                  expr = "histogram_quantile(0.95, sum by (le) (rate(app_request_latency_seconds_bucket[5m]))) > 1"

                  for = "2m"

                  labels = {
                    severity = "warning"
                  }

                  annotations = {
                    summary     = "SRE Demo App has high latency"
                    description = "P95 application latency is above 1 second."
                  }
                }
              ]
            }
          ]
        }
      }

      # ==========================================
      # Alertmanager
      # ==========================================
      alertmanager = {

        # Mount the existing Kubernetes Secret.
        # The Gmail App Password is NOT stored
        # inside Terraform or Git.
        extraSecretMounts = [
          {
            name       = "gmail-secret"
            mountPath  = "/etc/alertmanager/secrets"
            secretName = "alertmanager-gmail"
            readOnly   = true
          }
        ]

        config = {
          enabled = true

          # ======================================
          # Gmail SMTP Configuration
          # ======================================
          global = {
            smtp_smarthost = "smtp.gmail.com:587"

            smtp_from = "tobyarcea@gmail.com"

            smtp_auth_username = "tobyarcea@gmail.com"

            smtp_auth_password_file = "/etc/alertmanager/secrets/gmail-app-password"

            smtp_require_tls = true
          }

          # ======================================
          # Alert Routing
          # ======================================
          route = {
            receiver = "gmail-notifications"

            group_by = [
              "alertname",
              "severity"
            ]

            group_wait      = "10s"
            group_interval  = "5m"
            repeat_interval = "4h"
          }

          # ======================================
          # Email Receiver
          # ======================================
          receivers = [
            {
              name = "gmail-notifications"

              email_configs = [
                {
                  to = "tobyarcea@gmail.com"

                  send_resolved = true
                }
              ]
            }
          ]
        }
      }
    })
  ]
}
