pipeline {
    agent any

    // Parameter to choose host port dynamically
    parameters {
        string(name: 'HOST_PORT', defaultValue: '8081', description: 'Host port to expose Spring Boot app')
    }

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
                sh 'mvn clean package -DskipTests'
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
                  export DOCKER_CONFIG=/tmp/jenkins-docker
                  trivy image --exit-code 0 --severity LOW,MEDIUM $DOCKER_IMAGE
                  trivy image --exit-code 1 --severity HIGH,CRITICAL $DOCKER_IMAGE
                '''
            }
        }

        stage('Deploy to Docker') {
            steps {
                sh '''
                  export PATH=/opt/homebrew/bin:/usr/local/bin:$PATH

                  # Stop and remove any container named cicd-demo (to avoid port conflicts)
                  docker rm -f cicd-demo || true

                  # Also remove any other container using the HOST_PORT dynamically
                  OLD_CONTAINER=$(docker ps -q -f "publish=${HOST_PORT}")
                  if [ ! -z "$OLD_CONTAINER" ]; then
                    docker rm -f $OLD_CONTAINER
                  fi

                  # Run new container on the HOST_PORT parameter
                  docker run -d --name cicd-demo -p ${HOST_PORT}:8080 $DOCKER_IMAGE

                  # Wait for Spring Boot to start
                  echo "Waiting for Spring Boot to start..."
                  sleep 10

                  # Show last 20 log lines to verify app started
                  docker logs cicd-demo | tail -n 20

                  echo "Your Spring Boot app should now be available at http://localhost:${HOST_PORT}/"
                '''
            }
        }
    }

    post {
        always {
            echo 'Pipeline finished'
        }
    }
}