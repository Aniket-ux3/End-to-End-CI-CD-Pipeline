
resource "kubernetes_deployment" "app" {
  metadata { name = "devops-demo" }
  spec {
    replicas = 1
    selector { match_labels = { app = "devops-demo" } }
    template {
      metadata { labels = { app = "devops-demo" } }
      spec {
        container {
          image = "docker.io/aniket32/devops-demo:latest"
          name  = "app"
          port { container_port = 3000 }
        }
      }
    }
  }
}

resource "kubernetes_service" "svc" {
  metadata { name = "devops-demo-svc" }
  spec {
    selector = { app = "devops-demo" }
    port {
      port        = 3000
      target_port = 3000
    }

    type = "NodePort"
  }
}
