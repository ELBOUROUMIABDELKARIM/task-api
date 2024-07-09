pipeline {
    agent any
    stages {
        stage('Setup') {
            steps {
                // Verify Docker installation
                sh 'docker --version'
            }
        }
        stage('Checkout') {
            steps {
                git branch: 'master', url: 'https://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@github.com/ELBOUROUMIABDELKARIM/task-api'
            }
        }
        stage('Install dependencies') {
            steps {
                script {
                    sh 'sudo apt-get update -qq && sudo apt-get install --no-install-recommends -y build-essential libpq-dev libvips pkg-config'
                    sh 'bundle install'
                }
            }
        }
        stage('Run tests') {
            steps {
                sh 'bundle exec rspec'
            }
        }
        stage('Build Docker image') {
            steps {
                script {
                    docker.build("your-docker-repo/your-app:${env.BUILD_ID}")
                }
            }
        }
        stage('Deploy') {
            steps {
                script {
                    docker.withRegistry('https://index.docker.io/v1/', 'dockerhub-credentials') {
                        docker.image("your-docker-repo/your-app:${env.BUILD_ID}").push()
                    }
                }
            }
        }
    }
}
