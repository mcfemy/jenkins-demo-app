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
        stage('Build') {
            steps {
                echo 'Building application...'
                echo 'Build successful!'
            }
        }
        stage('Deploy') {
            steps {
                echo 'Deploying application...'
                echo 'Deployment successful!'
            }
        }
    }
}
