pipeline {
    environment {
    imagename = "prasadallu121/mytomcat1"
    registryCredential = 'dockerhub'
    dockerImage = ''
}
    agent any
    options {
        buildDiscarder(logRotator(numToKeepStr: '5'))
        timestamps()
		disableConcurrentBuilds()
    }
    tools {
        maven 'my-maven'
        terraform 'my-terraform'
            }
    /*triggers {
        pollSCM '* * * * *'
    } 
    */
    stages {
        stage("Git Checkout") {
            steps {
                script {
                    currentBuild.displayName = "Testing"
                    currentBuild.description = "Testing Project"
                    echo "$BUILD_NUMBER"
                }
                echo "Current BuildNumber is: $BUILD_NUMBER"
                git 'https://github.com/prasadallu121/Testing-Repo.git'
                }
        }
		stage("Build") {
            steps {
                sh """ 
                mvn clean install package
                cp -R webapp/target/webapp.war /var/lib/jenkins/Docker
                """
                }
            } 
        stage ("DockerImage") {
            steps {
                    dir ("/var/lib/jenkins/Docker") {
                    sh """
                    set +e
                    docker container rm tomcat1 -f
                    docker rmi mytomcat1
                    docker rmi tomcat
                    set -e
					docker build -t mytomcat1 .
                    docker run -dit --name tomcat1 -p 8000:8080 mytomcat1
                    docker tag mytomcat1 prasadallu121/mytomcat1
                    """
                    script {
                    dockerImage = docker.build imagename
                }
                }
                
			}
        }
		stage ("Docker Push") {
		steps {
		script {
		docker.withRegistry( '', registryCredential ) {
        dockerImage.push("$BUILD_NUMBER")
        dockerImage.push('latest')
		}
		       }
		      }
		                     }
		stage('Remove Unused docker image') {
        steps{
        sh "docker rmi $imagename:$BUILD_NUMBER"
        sh "docker rmi $imagename:latest"
             }
        }                     
        stage ("Terrraform") {
            steps {
                sh """
                terraform init
                terraform apply --auto-approve
                """
            }
        } 
    }
		post { 
        always { 
            cleanWs()
        }
    }

}
