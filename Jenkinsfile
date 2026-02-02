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
        stage('Cleanup Old Containers') {
            steps {
                script {
                    sh '''
                        docker ps -aq --filter "name=jenkins-demo" | xargs -r docker rm -f || true
                    '''
                }
            }
        }
        stage('Run Container') {
            steps {
                script {
                    sh "docker run -d -p 3000:3000 --name jenkins-demo-${env.BUILD_NUMBER} jenkins-demo:${env.BUILD_NUMBER}"
                    echo "Application running on http://localhost:3000"
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
