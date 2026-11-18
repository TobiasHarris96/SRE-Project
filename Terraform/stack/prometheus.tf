resource "helm_release" "prometheus" {
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus"

  namespace = kubernetes_namespace_v1.monitoring.metadata[0].name

  values = [
    yamlencode({
      serverFiles = {
        "alerting_rules.yml" = {
          groups = [
            {
              name = "sre-demo-app-alerts"

              rules = [
                {
                  alert = "SREDemoAppDown"
                  expr  = "up{service=\"sre-demo-service\"} == 0"
                  for   = "1m"

                  labels = {
                    severity = "critical"
                  }

                  annotations = {
                    summary     = "SRE Demo App is down"
                    description = "Prometheus cannot scrape the SRE Demo application."
                  }
                },

                {
                  alert = "SREDemoAppErrors"
                  expr  = "sum(rate(app_errors_total[5m])) > 0"
                  for   = "1m"

                  labels = {
                    severity = "warning"
                  }

                  annotations = {
                    summary     = "SRE Demo App is producing errors"
                    description = "Application errors have been detected."
                  }
                },

                {
                  alert = "SREDemoAppHighLatency"
                  expr  = "histogram_quantile(0.95, sum by (le) (rate(app_request_latency_seconds_bucket[5m]))) > 1"
                  for   = "2m"

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
    })
  ]
}
