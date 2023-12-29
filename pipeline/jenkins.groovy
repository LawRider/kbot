pipeline {
    agent any
    parameters {
        choice(name: 'OS', choices: ['linux', 'darwin', 'windows', 'all'], description: 'Pick OS')
	choice(name: 'ARCH', choices: ['amd64', 'arm64'], description: 'Pick ARCH')
    }
    
    environment {
    	GITHUB_TOKEN=credentials('github-token')
	REPO = 'https://github.com/LawRider/kbot'
	BRANCH = 'main'
    }
    
    stages {

	stage('clone') {
            steps {
                echo "CLONE REPOSITORY"
		git branch: "${BRANCH}", url: "${REPO}"
            }
        }

	stage('test') {
            steps {
                echo "TEST EXECUTION STARTED"
		sh "make test"
            }
        }

	stage('build') {
            steps {
                echo "BINARY BUILD EXECUTION STARTED FOR ${params.OS} (${params.ARCH})"
                sh "make ${params.OS} ${params.ARCH}"
            }
        }

	stage('image') {
            steps {
                echo "IMAGE BUILD EXECUTION STARTED FOR ${params.OS} (${params.ARCH})"
                sh "make image-${params.OS} ${params.ARCH}"
            }
        }

	stage('login to GHCR') {
            steps {
                sh "echo $GITHUB_TOKEN_PSW | docker login ghcr.io -u $GITHUB_TOKEN_USR --password-stdin"
            }
        }

        stage('push image') {
            steps {
                sh "make ${params.OS} ${params.ARCH} image push"
            }
        }
    }

    post {
        always {
            sh "docker logout"
        }
    }
}
