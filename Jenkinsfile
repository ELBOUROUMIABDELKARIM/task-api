pipeline {
    agent any

    environment {
        RAILS_ENV = 'test'
    }

    stages {
        stage('Checkout') {
            steps {
                git 'https://your-repository-url.git'
            }
        }

        stage('Install Dependencies') {
            steps {
                // Install Ruby and Bundler
                sh 'rvm install 2.7.2' // Make sure to use your Ruby version
                sh 'gem install bundler'

                // Install project dependencies
                sh 'bundle install'
            }
        }

        stage('Run Linter') {
            steps {
                // Run RuboCop to check for code style violations
                sh 'bundle exec rubocop'
            }
        }

        stage('Run Tests') {
            steps {
                // Run RSpec tests
                sh 'bundle exec rspec'
            }
        }

        stage('Build Docker Image') {
            steps {
                // Build the Docker image
                script {
                    dockerImage = docker.build("your-docker-repo/your-app-name:${env.BUILD_ID}")
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    docker.withRegistry('https://your-docker-registry', 'docker-credentials-id') {
                        dockerImage.push()
                    }
                }
            }
        }
    }

    post {
        always {
            // Clean up after the build
            cleanWs()
        }

        success {
            // Notify success
            echo 'Build succeeded.'
        }

        failure {
            // Notify failure
            echo 'Build failed.'
        }
    }
}
