pipeline {
    agent any

    environment {
        IMAGE_NAME = 'ensf400-project'
        TAG = 'latest'
    }

    stages {
        // Stage for building the image
        stage('Build') {
            steps {
                script {
                    sh 'docker build -t $IMAGE_NAME:$TAG .'
                }
            }
        }

        // Stage for pushing the image to DockerHub
        stage('Push to DockerHub') {
            steps {
                script {
                    withCredentials([usernamePassword(
                        credentialsId: 'docker-hub-credentials',
                        usernameVariable: 'DOCKER_HUB_USER',
                        passwordVariable: 'DOCKER_HUB_PASS'
                    )]) {
                        sh '''
                            echo "$DOCKER_HUB_PASS" | docker login -u "$DOCKER_HUB_USER" --password-stdin
                            docker tag $IMAGE_NAME:$TAG $DOCKER_HUB_USER/$IMAGE_NAME:$TAG
                            docker push $DOCKER_HUB_USER/$IMAGE_NAME:$TAG
                        '''
                    }
                }
            }
        }

        // Running the tests
        stage('Unit Tests') {
            agent {
                docker {
                    image 'gradle:7.6.1-jdk11'
                }
            }
            steps {
                sh './gradlew test'
            }
            post {
                always {
                    junit 'build/test-results/test/*.xml'
                }
            }
        }

        // Generate and save JavaDocs as an artifact
        stage('Generate JavaDocs') {
            agent {
                docker {
                    image 'gradle:7.6.1-jdk11'
                }
            }
            steps {
                sh './gradlew javadoc'
                archiveArtifacts allowEmptyArchive: true, artifacts: 'build/docs/javadoc/**'
            }
        }

        // Stage for pulling the image and running the application
        stage('Deploy Application') {
            steps {
                script {
                    withCredentials([usernamePassword(
                        credentialsId: 'docker-hub-credentials',
                        usernameVariable: 'DOCKER_HUB_USER',
                        passwordVariable: 'DOCKER_HUB_PASS'
                    )]) {
                        sh '''
                            echo "$DOCKER_HUB_PASS" | docker login -u "$DOCKER_HUB_USER" --password-stdin
                            docker pull $DOCKER_HUB_USER/$IMAGE_NAME:$TAG
                            docker run -di -p 8081:8080 $DOCKER_HUB_USER/$IMAGE_NAME:$TAG
                        '''
                    }
                }
            }
        }

        // Static Analysis with SonarQube (simplified version)
        stage('Static Analysis') {
            agent {
                docker {
                    image 'sonarsource/sonar-scanner-cli:latest'
                }
            }
            environment {
                SONAR_HOST_URL = 'http://your-sonarqube-server:9000'  // Update with your SonarQube server URL
                SONAR_TOKEN = credentials('your-sonar-token-id')     // Jenkins credentials
            }
            steps {
                sh './gradlew sonarqube -Dsonar.host.url=$SONAR_HOST_URL -Dsonar.login=$SONAR_TOKEN'
            }
        }
    }
}
