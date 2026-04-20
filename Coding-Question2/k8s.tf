resource "kubernetes_namespace_v1" "main" {
  for_each = toset(["asiayo"])

  metadata {
    name = each.value
  }
}


# ALB
resource "kubernetes_manifest" "ingress_class_params_alb" {
  manifest = {
    "apiVersion" = "eks.amazonaws.com/v1"
    "kind"       = "IngressClassParams"
    "metadata" = {
      "name" = "alb"
    }
    "spec" = {
      "scheme" = "internet-facing"
        "tags" = [{
          "key" = "ALB"
          "value" = "external"
        }]
    }
  }
}

resource "kubernetes_ingress_class_v1" "alb" {
  metadata {
    name = "alb"
    annotations = {
      "ingressclass.kubernetes.io/is-default-class" = "true"
    }
  }

  spec {
    controller = "eks.amazonaws.com/alb"

    parameters {
      api_group = "eks.amazonaws.com"
      kind      = "IngressClassParams"
      name      = "alb"
    }
  }

  # Ensure the params exist before the class tries to reference them
  depends_on = [kubernetes_manifest.ingress_class_params_alb]
}

# EBS PV
resource "kubernetes_storage_class_v1" "auto_ebs_sc" {
  metadata {
    name = "ebs-sc"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }

  # The driver for AWS EBS CSI
  storage_provisioner = "ebs.csi.eks.amazonaws.com"
  volume_binding_mode = "WaitForFirstConsumer"

  parameters = {
    type      = "gp3"
    encrypted = "true"
  }

  allowed_topologies {
    match_label_expressions {
      key = "eks.amazonaws.com/compute-type"
      values = [
        "auto"
      ]
    }
  }
}