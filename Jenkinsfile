pipeline {
  agent any

  environment {
    DOCKERHUB = credentials('dockerhub-creds')
    IMAGE = "${DOCKERHUB_USR}/devops-demo"
    TAG = "${env.GIT_COMMIT}"
  }

  stages {
    stage('Checkout') {
      steps { checkout scm }
    }

    stage('Build Docker Image') {
      steps {
        sh "docker build -t ${IMAGE}:${TAG} ."
        sh "docker tag ${IMAGE}:${TAG} ${IMAGE}:latest"
      }
    }

    stage('Push to DockerHub') {
      steps {
        sh "echo ${DOCKERHUB_PSW} | docker login -u ${DOCKERHUB_USR} --password-stdin"
        sh "docker push ${IMAGE}:${TAG}"
        sh "docker push ${IMAGE}:latest"
      }
    }

    stage('Deploy to kind (K8s)') {
      steps {
        sh "kubectl set image deployment/devops-demo app=${IMAGE}:${TAG} --record || true"
        sh "kubectl rollout status deployment/devops-demo || true"
      }
    }
    stage('Terraform Import') {
      when { expression { fileExists('terraform/main.tf') } }
      steps {
        sh '''
           cd terraform
           terraform init
           if ! terraform state show kubernetes_deployment.app >/dev/null 2>&1; then
             terraform import kubernetes_deployment.app default/devops-demo
           else
             echo "Deployment already imported. Skipping..."
           fi
 
           if ! terraform state show kubernetes_service.svc >/dev/null 2>&1; then
             terraform import kubernetes_service.svc default/devops-demo-svc
           else
             echo "Service already imported. Skipping..."
           fi
        '''
      }
    }

    stage('Terraform Apply') {
      when { expression { fileExists('terraform/main.tf') } }
      steps {
        sh "cd terraform && terraform apply -auto-approve"
      }
    }
  }
}
