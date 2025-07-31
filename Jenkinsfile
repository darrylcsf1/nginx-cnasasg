pipeline {
  agent any
  environment {
    IMAGE = 'yourdockerhubusername/nginx-site:${BUILD_NUMBER}'
  }

  stages {
    stage('Clone') {
      steps {
        git 'https://github.com/YOUR_USERNAME/nginx-site.git'
      }
    }

    stage('Build') {
      steps {
        sh 'docker build -t $IMAGE .'
      }
    }

    stage('Push') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'USER', passwordVariable: 'PASS')]) {
          sh 'echo $PASS | docker login -u $USER --password-stdin'
          sh 'docker push $IMAGE'
        }
      }
    }
  }
}
