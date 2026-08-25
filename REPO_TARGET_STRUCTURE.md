# Target Repository Structure

The completed repository should be close to:

```text
jenkins-ci-cd-lab/
│
├── README.md
├── LICENSE
├── Makefile
├── docker-compose.yml
├── .env.demo
├── .gitignore
├── versions.env
│
├── app/
│   ├── app.py
│   ├── requirements.txt
│   ├── requirements-dev.txt
│   ├── Dockerfile
│   └── tests/
│       └── test_app.py
│
├── jenkins/
│   ├── Dockerfile
│   ├── plugins.txt
│   ├── casc/
│   │   └── jenkins.yaml
│   ├── job-dsl/
│   │   └── jobs.groovy
│   └── pipelines/
│       ├── Jenkinsfile.ci
│       └── Jenkinsfile.cd
│
├── kind/
│   └── kind-config.yaml
│
├── k8s/
│   ├── namespace.yaml
│   ├── deployment.yaml
│   └── service.yaml
│
├── scripts/
│   ├── setup.sh
│   ├── doctor.sh
│   ├── bootstrap-nexus.sh
│   ├── configure-kind-registry.sh
│   ├── generate-jenkins-kubeconfig.sh
│   ├── create-k8s-secret.sh
│   ├── trigger-demo.sh
│   ├── verify.sh
│   ├── status.sh
│   ├── teardown.sh
│   ├── reset.sh
│   ├── install-prerequisites-ubuntu.sh
│   └── lib/
│       └── common.sh
│
├── docs/
│   ├── architecture.md
│   ├── student-lab.md
│   ├── instructor-guide.md
│   ├── troubleshooting.md
│   └── VERSIONS.md
│
└── generated/
    └── .gitkeep
```

## Runtime/generated data that must not be committed

Examples:

```text
.env
generated/jenkins-kubeconfig
generated/*.log
generated/*.tmp
jenkins_home/
nexus-data/
```

Use named Docker volumes for Jenkins and Nexus runtime state where practical.
