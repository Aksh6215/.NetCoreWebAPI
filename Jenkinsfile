pipeline {
    agent any

    environment {
        ACR_NAME = 'codecraftacr'
        AZURE_CREDENTIALS_ID = 'jenkins-pipeline-sp'
        ACR_LOGIN_SERVER = "${ACR_NAME}.azurecr.io"
        IMAGE_NAME = 'app'
        IMAGE_TAG = 'latest'
        RESOURCE_GROUP = 'codecraft-rg'
        AKS_CLUSTER = 'codecraft-aks'
        TF_WORKING_DIR = './terraform'
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/Aksh6215/.NetCoreWebAPI.git'
            }
        }

        stage('Build .NET App') {
            steps {
                bat 'dotnet publish app/app.csproj -c Release -o out'
            }
        }

        stage('Build Docker Image') {
            steps {
                bat "docker build -t %ACR_LOGIN_SERVER%/%IMAGE_NAME%:%IMAGE_TAG% -f app/Dockerfile app"
            }
        }

         stage('Deploy') {
            steps {
                withCredentials([azureServicePrincipal(credentialsId: AZURE_CREDENTIALS_ID)]) {
                    bat "az login --service-principal -u $AZURE_CLIENT_ID -p $AZURE_CLIENT_SECRET --tenant $AZURE_TENANT_ID"
                    bat "powershell Compress-Archive -Path ./publish/* -DestinationPath ./publish.zip -Force"
                    bat "az webapp deploy --resource-group $RESOURCE_GROUP --name $APP_SERVICE_NAME --src-path ./publish.zip --type zip"
                }
            }
        }
    
        stage('Login to ACR') {
            steps {
                bat "az acr login --name %ACR_NAME%"
            }
        }

        stage('Push Docker Image to ACR') {
            steps {
                bat "docker push %ACR_LOGIN_SERVER%/%IMAGE_NAME%:%IMAGE_TAG%"
            }
        }

        stage('Get AKS Credentials') {
            steps {
                bat "az aks get-credentials --resource-group %RESOURCE_GROUP% --name %AKS_CLUSTER% --overwrite-existing"
            }
        }

        stage('Deploy to AKS') {
            steps {
                bat "kubectl apply -f app/test.yaml"
            }
        }
    }

    post {
        success {
            echo 'All stages completed successfully!'
        }
        failure {
            echo 'Build failed.'
        }
    }
}
