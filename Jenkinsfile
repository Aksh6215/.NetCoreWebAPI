pipeline {
  agent any

  environment {
    ACR_NAME = 'codecraftacr.azurecr.io'
    IMAGE_NAME = 'app'
    IMAGE_TAG = 'latest'
    KUBECONFIG_CREDENTIALS_ID = 'azure-kubeconfig'
  }

  stages {
    stage('Clone Repo') {
      steps {
        git 'https://github.com/yourusername/your-repo.git'
      }
    }

    stage('Build Docker Image') {
      steps {
        dir('app') {
          script {
            docker.build("${ACR_NAME}/${IMAGE_NAME}:${IMAGE_TAG}")
          }
        }
      }
    }

    stage('Push to ACR') {
      steps {
        script {
          sh 'az acr login --name codecraftacr'
          sh "docker push ${ACR_NAME}/${IMAGE_NAME}:${IMAGE_TAG}"
        }
      }
    }

    stage('Deploy to AKS') {
      steps {
        withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG')]) {
          sh '''
            kubectl apply -f k8s/deployment.yaml
            kubectl apply -f k8s/service.yaml
          '''
        }
      }
    }
  }
}
