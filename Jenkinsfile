pipeline {
    agent {
        docker {
            image 'jenkins-ruby-rbenv'
            args '-u root:root'
        }
    }

    environment {
        DATABASE_URL = "postgres://postgres:postgres@postgres_container:5432/project_development_test"
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'master', url: 'https://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@github.com/ELBOUROUMIABDELKARIM/task-api'
            }
        }
        stage('Install Dependencies') {
            steps {
                sh 'bundle install'
            }
        }
        stage('Lint') {
            steps {
                sh 'bundle exec rubocop'
            }
        }
        stage('Test') {
            steps {
                sh 'bundle exec rake db:create db:schema:load'
                sh 'bundle exec rspec'
            }
        }
    }
}
