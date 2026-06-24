resource "helm_release" "vault" {
  name      = "vault"
  namespace = kubernetes_namespace_v1.vault.metadata[0].name

  repository = "https://helm.releases.hashicorp.com"
  chart      = "vault"

  values = [
    yamlencode({
      server = {
        dev = {
          enabled = true
        }

        serviceAccount = {
          create = true
          name   = "vault"
        }

        service = {
          type = "LoadBalancer"

          annotations = {
            "service.beta.kubernetes.io/aws-load-balancer-type"            = "external"
            "service.beta.kubernetes.io/aws-load-balancer-nlb-target-type" = "ip"
            "service.beta.kubernetes.io/aws-load-balancer-scheme"          = "internet-facing"
          }
        }
      }

      injector = {
        enabled = true
      }
    })
  ]

  depends_on = [
    kubernetes_namespace_v1.vault
  ]
}
