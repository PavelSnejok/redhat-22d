provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.data_eks_cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.data_eks_cluster.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.data_eks_cluster_auth.token
  }
}

resource "helm_release" "ingress_nginx" {
  name       = "ingress-nginx"
  chart      = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  namespace  = "kube-system"

  set {
    name  = "controller.replicaCount"
    value = "1"
  }

#   set {
#     name  = "defaultBackend.enabled"
#     value = "true"
#   }

  depends_on = [
    aws_eks_cluster.eks_cluster
  ]
}

