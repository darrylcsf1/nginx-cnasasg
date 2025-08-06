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

    stage('Secret Scan with GitGuardian') {
      steps {
        withCredentials([string(credentialsId: 'gitguardian-token', variable: '39b2f8df-026e-40aa-bc2f-bc87b581ac4c')]) {
          sh '''
            echo "Scanning repository for secrets..."
            ggshield secret scan repo . --exit-zero
          '''
        }
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
          echo "Running Trivy vulnerability scan..."
          trivy image --exit-code 0 --severity CRITICAL,HIGH $IMAGE
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

            echo "Deploying to GKE..."
            kubectl replace -f k8s/deployment.yaml --force --validate=false
            kubectl replace -f k8s/service.yaml --force --validate=false
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

