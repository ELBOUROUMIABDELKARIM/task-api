pipeline {
    agent any

    environment {
        RAILS_ENV = 'test'
    }

    stages {
        stage('Checkout') {
            steps {
                git 'https://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@github.com/ELBOUROUMIABDELKARIM/task-api'
            }
        }

        stage('Install Dependencies') {
            steps {
                bat 'rvm install 3.2.3'
                bat 'gem install bundler'
                bat 'bundle install'
            }
        }

        stage('Run Tests') {
            steps {
                bat 'bundle exec rspec'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    dockerImage = docker.build("abdelkarimelbouroumi/task-ruby-api:${env.BUILD_ID}")
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    docker.withRegistry('https://index.docker.io/v1/', '2188e3cf-9082-4c18-9644-81a7b2350f7d') {
                        dockerImage.push()
                    }
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }

        success {
            echo 'Build succeeded.'
        }

        failure {
            echo 'Build failed.'
        }
    }
}
