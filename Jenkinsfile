pipeline {
    agent any

    environment {
        // Docker Hub credentials
        DOCKERHUB_CREDENTIALS = credentials('docker-hub-credentials')
        // EC2 SSH credentials
        SSH_CREDENTIALS = credentials('ssh-deploy-credentials')
        // Docker Image Name
        IMAGE_NAME = "midhun777/shellfolio"
        // AWS EC2 Instance Details
        EC2_USER = "ec2-user" // or your specific user normally default
        EC2_HOST = "54.162.193.235" // replace with your EC2 public IP or DNS 
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/MidhunAravindan/shellfolio.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    docker.build("${env.IMAGE_NAME}:latest")
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                script {
                    docker.withRegistry('https://registry.hub.docker.com', 'docker-hub-credentials') {
                        docker.image("${env.IMAGE_NAME}:latest").push()
                    }
                }
            }
        }

        stage('Deploy to EC2') {
            steps {
                sshCommand remote: [
                    name: 'EC2',
                    host: env.EC2_HOST,
                    user: env.EC2_USER,
                    identityFile: env.SSH_CREDENTIALS,
                    allowAnyHosts: true
                ], command: """
                    docker pull ${env.IMAGE_NAME}:latest
                    sudo docker stop shellfolio || true
                    sudo docker rm shellfolio || true
                    sudo docker run -d -p 80:80 -p 443:443 --name shellfolio ${env.IMAGE_NAME}:latest
                """
            }
        }
    }

    post {
        success {
            echo 'Deployment Successful!'
        }
        failure {
            echo 'Deployment Failed.'
        }
    }
}
