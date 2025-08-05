pipeline {
  agent any

  environment {
    IMAGE = "dankmogus1/nginx-site:${BUILD_NUMBER}"
    PROJECT_ID = "generated-motif-467509-b6"
    CLUSTER_NAME = "cnas-cluster-1"
    CLUSTER_ZONE = "us-central1"
    USE_GKE_GCLOUD_AUTH_PLUGIN = "True"
  }

  stages {
    stage('Clone') {
      steps {
        git branch: 'main', url: 'https://github.com/darrylcsf1/nginx-cnasasg'
      }
    }

    stage('Build') {
      steps {
        sh "docker build -t $IMAGE ."
      }
    }

    stage('Scan with Trivy') {
      steps {
        sh '''
          if ! command -v trivy &> /dev/null; then
            echo "Installing Trivy..."
            sudo apt update
            sudo apt install -y curl gnupg lsb-release
            curl -fsSL https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo gpg --dearmor -o /usr/share/keyrings/trivy.gpg
            echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/trivy.list
            sudo apt update
            sudo apt install -y trivy
          fi

          echo "Running Trivy vulnerability scan..."
          trivy image --exit-code 1 --severity CRITICAL,HIGH $IMAGE
        '''
      }
    }

    stage('Push') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'dockerhub-cnas-credentials', usernameVariable: 'USER', passwordVariable: 'PASS')]) {
          sh 'echo $PASS | docker login -u $USER --password-stdin'
          sh "docker push $IMAGE"
        }
      }
    }

    stage('Deploy to GKE') {
      steps {
        withCredentials([file(credentialsId: 'cnas-gcp-key', variable: 'GOOGLE_APPLICATION_CREDENTIALS')]) {
          sh """
            gcloud auth activate-service-account --key-file=$GOOGLE_APPLICATION_CREDENTIALS
            gcloud config set project $PROJECT_ID
            gcloud container clusters get-credentials $CLUSTER_NAME --zone $CLUSTER_ZONE
            kubectl apply -f k8s/deployment.yaml
            kubectl apply -f k8s/service.yaml
          """
        }
      }
    }
  }

  post {
    success {
      echo "Deployment to GKE successful!"
    }
    failure {
      echo "Deployment failed. Check Jenkins logs."
    }
  }
}
