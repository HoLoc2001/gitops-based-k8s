# resource "helm_release" "vault" {
#   name      = "vault"
#   namespace = kubernetes_namespace_v1.vault.metadata[0].name

#   repository = "https://helm.releases.hashicorp.com"
#   chart      = "vault"

#   values = [
#     yamlencode({
#       server = {
#         dev = {
#           enabled = true
#         }
#       }

#       injector = {
#         enabled = true
#       }
#     })
#   ]

#   set = [
#     {
#       name  = "clusterName"
#       value = var.cluster_name
#     },
#     {
#       name  = "region"
#       value = var.aws_region
#     },
#     {
#       name  = "vpcId"
#       value = var.vpc_id
#     },
#     {
#       name  = "serviceAccount.create"
#       value = "false"
#     },
#     {
#       name  = "serviceAccount.name"
#       value = "aws-load-balancer-controller"
#     }
#   ]

# }


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

        # --- BẬT LOAD BALANCER Ở ĐÂY ---
        service = {
          type = "LoadBalancer"
          # Nếu bạn muốn dùng Network Load Balancer (NLB) của AWS thay vì Classic (CLB) mặc định:
          annotations = {
            "service.beta.kubernetes.io/aws-load-balancer-type"            = "external"
            "service.beta.kubernetes.io/aws-load-balancer-nlb-target-type" = "ip"
            "service.beta.kubernetes.io/aws-load-balancer-scheme"          = "internet-facing" # hoặc "internal" nếu chỉ dùng nội bộ
          }
        }

        # Đưa serviceAccount vào trong yamlencode cho đồng bộ
        serviceAccount = {
          create = false
          name   = "aws-load-balancer-controller"
        }
      }

      injector = {
        enabled = true
      }
    })
  ]

  # Giữ lại các biến custom khác nếu chart của bạn thực sự nhận chúng ở cấp cao nhất (root level)
  set = [
    {
      name  = "clusterName"
      value = var.cluster_name
    },
    {
      name  = "region"
      value = var.aws_region
    },
    {
      name  = "vpcId"
      value = var.vpc_id
    }
  ]
}
