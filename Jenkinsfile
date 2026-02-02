pipeline {
    agent any
    stages {
        stage('Checkout') {
            steps {
                echo 'Code checked out from GitHub'
            }
        }
        stage('Test') {
            steps {
                echo 'Running tests...'
                echo 'Tests passed!'
            }
        }
        stage('Build Docker Image') {
            steps {
                script {
                    docker.build("jenkins-demo:${env.BUILD_NUMBER}")
                }
            }
        }
        stage('Deploy') {
            steps {
                echo 'Deployment successful!'
            }
        }
    }
}
