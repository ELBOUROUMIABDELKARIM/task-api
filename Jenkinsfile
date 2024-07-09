pipeline {
    agent any

    environment {
        RAILS_ENV = 'test'
    }

    stages {
        stage('Checkout') {
            steps {
                git 'https://github.com/ELBOUROUMIABDELKARIM/task-api'
            }
        }

        stage('Install Dependencies') {
            steps {
                sh 'rvm install 3.2.3'
                sh 'gem install bundler'
                sh 'bundle install'
            }
        }

        stage('Run Linter') {
            steps {
                sh 'bundle exec rubocop'
            }
        }

        stage('Run Tests') {
            steps {
                sh 'bundle exec rspec'
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
