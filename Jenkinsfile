pipeline {
    agent any

    tools {
        maven 'Maven3'
        jdk 'jdk17'
    }

    environment {
        DOCKER_IMAGE = 'navyatatikonda7/cicd-demo:latest'
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
                  export PATH=/opt/homebrew/bin:/usr/local/bin:$PATH
                  dependency-check \
                    --scan . \
                    --format HTML \
                    --out dependency-report \
                    --disableAssembly
                '''
            }
        }

        stage('Docker Build & Push') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh '''
                      export PATH=/opt/homebrew/bin:/usr/local/bin:$PATH

                      echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                      docker build -t $DOCKER_IMAGE .
                      docker push $DOCKER_IMAGE
                    '''
                }
            }
        }

        stage('Trivy Scan') {
            steps {
                sh '''
                  export PATH=/opt/homebrew/bin:$PATH
                  export TRIVY_DISABLE_DOCKER_CREDENTIALS=true
                  trivy image --exit-code 0 --severity LOW,MEDIUM $DOCKER_IMAGE
                  trivy image --exit-code 1 --severity HIGH,CRITICAL $DOCKER_IMAGE
                '''
            }
        }

        stage('Deploy to Docker') {
            steps {
                sh '''
                  export PATH=/opt/homebrew/bin:/usr/local/bin:$PATH
                  docker rm -f cicd-demo || true
                  docker run -d --name cicd-demo -p 8081:8080 $DOCKER_IMAGE
                '''
            }
        }
    }
}