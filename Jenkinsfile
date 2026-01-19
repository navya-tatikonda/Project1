pipeline {
    agent any

    tools {
        maven 'maven'
        jdk 'jdk17'
    }

    environment {
        SONARQUBE_SERVER = 'sonarqube'
        DOCKER_IMAGE = 'cicd-demo:latest'
    }

    triggers {
        githubPush()
    }

    stages {

        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('Build & Unit Test') {
            steps {
                sh 'mvn clean test'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('sonarqube') {
                    sh 'mvn sonar:sonar'
                }
            }
        }

        stage('OWASP Dependency Check') {
            steps {
                sh '''
                dependency-check.sh \
                --scan . \
                --format HTML \
                --out dependency-report \
                --disableAssembly
                '''
            }
        }

        stage('Package JAR') {
            steps {
                sh 'mvn package'
            }
        }

        stage('Docker Build') {
            steps {
                sh 'docker build -t $DOCKER_IMAGE .'
            }
        }

        stage('Trivy Scan') {
            steps {
                sh '''
                trivy image --exit-code 0 --severity LOW,MEDIUM $DOCKER_IMAGE
                trivy image --exit-code 1 --severity HIGH,CRITICAL $DOCKER_IMAGE
                '''
            }
        }

        stage('Deploy to Docker') {
            steps {
                sh '''
                docker rm -f cicd-demo || true
                docker run -d --name cicd-demo $DOCKER_IMAGE
                '''
            }
        }
    }
}
