output "vault_addr" {
  value = "http://localhost:8200"
}

resource "time_sleep" "wait_120_seconds" {
  depends_on = [helm_release.vault]

  create_duration = "1s"
}

data "kubernetes_service_v1" "vault_lb" {
  metadata {
    name      = "vault"
    namespace = "vault"
  }

  depends_on = [time_sleep.wait_120_seconds, helm_release.vault]
}


output "vault_url" {
  value       = "http://${data.kubernetes_service_v1.vault_lb.status[0].load_balancer[0].ingress[0].hostname}:8200"
  description = "Đường dẫn truy cập vào Vault UI công khai"
}
