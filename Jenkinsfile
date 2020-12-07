pipeline {
  agent       { label 'docker' }
  options     {
    buildDiscarder(logRotator(numToKeepStr: '5'))
    timestamps()
  }
  triggers    { cron('@weekly') }
  environment {
    CI = 'true'
    CONTAINER = 'prometheus'
  }
  stages {
    stage('Build') {
      steps {
        script {
          props = readProperties file: "./version"
          docker.withRegistry("https://utexas-glib-it-docker-local.jfrog.io", 'ad6f56cd-eb41-46b7-a4d3-b83e52919eb7') {
            image = docker.build("utexas-glib-it-docker-local.jfrog.io/${props.NAME}-${props.RELEASE}:${props.MAJOR}.${props.MINOR}.${props.HOTFIX}-${env.BUILD_NUMBER}", "--pull ./ ")
            image.push()
            image.push("${props.MAJOR}.${props.MINOR}.${props.HOTFIX}-${env.GIT_BRANCH}-${env.BUILD_NUMBER}")
            image.push("${props.MAJOR}.${props.MINOR}.${props.HOTFIX}-${env.GIT_BRANCH}")
            image.push("${props.MAJOR}.${props.MINOR}.${props.HOTFIX}")
            image.push("${props.MAJOR}.${props.MINOR}")
            image.push("${props.MAJOR}")
            image.push('latest')
          }
        }
      }
    }
  }
  post {
    always {
       deleteDir()
    }
    success {
      slackSend message: "${currentBuild.currentResult}: ${props.NAME}-${props.RELEASE}:${props.MAJOR}.${props.MINOR}.${props.HOTFIX}-<${env.GIT_URL}|${env.GIT_BRANCH}>-${env.BUILD_NUMBER} (<${env.BUILD_URL}|Open>)"
    }
    failure {
      slackSend message: "${currentBuild.currentResult}: ${props.NAME}-${props.RELEASE}:${props.MAJOR}.${props.MINOR}.${props.HOTFIX}-<${env.GIT_URL}|${env.GIT_BRANCH}>-${env.BUILD_NUMBER} (<${env.BUILD_URL}|Open>)"
    }
    unstable {
      slackSend message: "${currentBuild.currentResult}: ${props.NAME}-${props.RELEASE}:${props.MAJOR}.${props.MINOR}.${props.HOTFIX}-<${env.GIT_URL}|${env.GIT_BRANCH}>-${env.BUILD_NUMBER} (<${env.BUILD_URL}|Open>)"
    }
  }
}
