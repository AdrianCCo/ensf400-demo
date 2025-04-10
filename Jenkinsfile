pipeline {
    agent any
    
    environment {
        // Define environment variables
        DOCKER_HUB_CREDS = credentials('docker-hub-credentials')
        DOCKER_IMAGE_NAME = 'yourusername/your-application'
        DOCKER_IMAGE_TAG = "${BUILD_NUMBER}-${GIT_COMMIT.substring(0, 7)}"
    }
    
    stages {
        stage('Checkout') {
            steps {
                // Checkout code from repository
                checkout scm
                echo "Checked out code from repository"
            }
        }
        
        stage('Build') {
            steps {
                // Build application using Maven
                sh 'mvn clean package -DskipTests'
                echo "Application built successfully"
            }
        }
        
        stage('Unit Tests') {
            steps {
                // Run unit tests
                sh 'mvn test'
            }
            post {
                // Publish JUnit test results
                always {
                    junit '**/target/surefire-reports/*.xml'
                    echo "Unit tests completed"
                }
            }
        }
        
        stage('Code Quality Analysis') {
            steps {
                // Run SonarQube analysis
                withSonarQubeEnv('SonarQube') {
                    sh 'mvn sonar:sonar'
                }
                echo "SonarQube analysis completed"
            }
        }
        
        stage('Generate Javadocs') {
            steps {
                // Generate Javadocs
                sh 'mvn javadoc:javadoc'
                echo "Javadocs generated successfully"
            }
            post {
                success {
                    // Archive Javadocs
                    archiveArtifacts artifacts: 'target/site/apidocs/**', fingerprint: true
                }
            }
        }
        
        stage('Security Scan') {
            steps {
                // Run OWASP Dependency Check
                sh 'mvn org.owasp:dependency-check-maven:check'
                echo "Security scan completed"
            }
            post {
                always {
                    // Publish dependency check results
                    publishHTML(target: [
                        allowMissing: false,
                        alwaysLinkToLastBuild: true,
                        keepAll: true,
                        reportDir: 'target',
                        reportFiles: 'dependency-check-report.html',
                        reportName: 'Dependency Check Report'
                    ])
                }
            }
        }
        
        stage('Performance Testing') {
            steps {
                // Run JMeter tests
                sh 'mvn jmeter:jmeter'
                echo "Performance tests completed"
            }
            post {
                always {
                    // Publish JMeter results
                    perfReport sourceDataFiles: 'target/jmeter/results/*.jtl', 
                             errorFailedThreshold: 20, 
                             errorUnstableThreshold: 10, 
                             errorUnstableResponseTimeThreshold: '4000'
                }
            }
        }
        
        stage('Build Docker Image') {
            steps {
                // Build Docker image
                sh """
                docker build -t ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG} .
                docker tag ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG} ${DOCKER_IMAGE_NAME}:latest
                """
                echo "Docker image built successfully"
            }
        }
        
        stage('Push to DockerHub') {
            steps {
                // Login to DockerHub and push image
                sh """
                echo ${DOCKER_HUB_CREDS_PSW} | docker login -u ${DOCKER_HUB_CREDS_USR} --password-stdin
                docker push ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}
                docker push ${DOCKER_IMAGE_NAME}:latest
                docker logout
                """
                echo "Docker image pushed to DockerHub"
            }
        }
        
        stage('Deploy Application') {
            steps {
                // Deploy the application
                script {
                    // Check if container is already running and stop it
                    sh '''
                    CONTAINER_ID=$(docker ps -q --filter name=your-application)
                    if [ -n "$CONTAINER_ID" ]; then
                        docker stop your-application
                        docker rm your-application
                    fi
                    
                    # Deploy the new container
                    docker run -d --name your-application -p 8080:8080 ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}
                    '''
                    echo "Application deployed successfully"
                }
            }
        }
    }
    
    post {
        success {
            echo "CI/CD Pipeline completed successfully!"
        }
        failure {
            echo "CI/CD Pipeline failed!"
            // You can add notification steps here (email, Slack, etc.)
        }
        always {
            // Clean up workspace
            cleanWs()
        }
    }
}
