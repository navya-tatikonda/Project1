pipeline {
    agent any

    tools {
        maven 'Maven3'
        jdk 'jdk17'
    }

    environment {
        SONARQUBE_SERVER = 'sonarqube'
        DOCKER_IMAGE = 'navyatatikonda7/cicd-demo:latest'
        PATH = "/opt/homebrew/bin:/usr/local/bin/docker:${env.PATH}"
        DOCKERHUB_USERNAME = "navyatatikonda7"
    }

    triggers {
        githubPush()
    }

    stages {

        stage('Checkout Code') {
            steps {
                git branch: 'main',
                url: 'https://github.com/navya-tatikonda/Project3.git'
            }
        }

        stage('Build with Maven') {
            steps {
                sh 'mvn clean package'
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
                export PATH=/opt/homebrew/bin:$PATH
                dependency-check \
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
        stage('Trivy DB Update') {
             steps {
                 sh '''
                 export PATH=/opt/homebrew/bin:$PATH
                 trivy image --download-db-only
           '''
            }
        }
        
        stage('Trivy Scan') {
            steps {
                sh '''
                export PATH=/opt/homebrew/bin:$PATH
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