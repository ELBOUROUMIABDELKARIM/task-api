pipeline {
    agent any
    environment {
        PATH = "/usr/local/rbenv/bin:/usr/local/rbenv/shims:$PATH"
    }
    stages {
        stage('Setup') {
            steps {
                // Verify Docker and Ruby installations
                sh 'docker --version'
                sh '/bin/bash -c "source /etc/profile.d/rbenv.sh && ruby --version"'
                sh '/bin/bash -c "source /etc/profile.d/rbenv.sh && bundler --version"'
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
                    sh 'sudo apt-get update -qq && sudo apt-get install --no-install-recommends -y libpq-dev libvips pkg-config'
                    sh '/bin/bash -c "source /etc/profile.d/rbenv.sh && bundle install"'
                }
            }
        }
        stage('Run tests') {
            steps {
                sh '/bin/bash -c "source /etc/profile.d/rbenv.sh && bundle exec rspec"'
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
