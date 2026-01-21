pipeline {
    agent any

    tools {
        maven 'maven3'
        jdk 'jdk17'
    }

    environment {
        SONARQUBE_SERVER = 'sonarqube'
        DOCKER_IMAGE = 'navyatatikonda7/cicd-demo:latest'
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

        stage('Docker Build & Push') {
            steps {
                withDockerRegistry(credentialsId: 'dockerhub', url: '') {
                    sh '''
                    docker build -t $DOCKER_IMAGE .
                    docker push $DOCKER_IMAGE
                    '''
                }
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
                docker run -d --name cicd-demo -p 8081:8080 $DOCKER_IMAGE
                '''
            }
        }
    }
}