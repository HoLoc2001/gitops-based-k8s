data "aws_iam_policy_document" "alb_controller_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type = "Federated"
      identifiers = [
        aws_iam_openid_connect_provider.eks.arn
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(var.oidc_issuer_url, "https://", "")}:sub"
      values = [
        "system:serviceaccount:kube-system:aws-load-balancer-controller"
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(var.oidc_issuer_url, "https://", "")}:aud"
      values = [
        "sts.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_role" "alb_controller" {
  name               = "${var.project_name}-alb-controller-role"
  assume_role_policy = data.aws_iam_policy_document.alb_controller_assume_role.json
}

resource "aws_iam_role_policy_attachment" "alb_controller" {
  role       = aws_iam_role.alb_controller.name
  policy_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/AWSLoadBalancerControllerIAMPolicy"
}

