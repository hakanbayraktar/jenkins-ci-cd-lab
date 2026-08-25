def repo = System.getenv('GIT_REPO_URL') ?: 'https://github.com/hakanbayraktar/jenkins-ci-cd-lab.git'

pipelineJob('flask-app-ci') {
  description('Build, test, scan, publish, then trigger CD. TRAINING ONLY.')
  definition {
    cpsScm {
      scm {
        git {
          remote { url(repo) }
          branches('*/main')
          extensions { wipeOutWorkspace() }
        }
      }
      scriptPath('jenkins/pipelines/Jenkinsfile.ci')
      lightweight(false)
    }
  }
}

pipelineJob('flask-app-cd') {
  description('Deploy a previously built immutable Nexus image. Never rebuilds.')
  parameters { stringParam('IMAGE_TAG', '', 'Required immutable image tag produced by flask-app-ci') }
  definition {
    cpsScm {
      scm {
        git {
          remote { url(repo) }
          branches('*/main')
          extensions { wipeOutWorkspace() }
        }
      }
      scriptPath('jenkins/pipelines/Jenkinsfile.cd')
      lightweight(false)
    }
  }
}
