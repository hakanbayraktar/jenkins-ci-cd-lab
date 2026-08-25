# CODEX MASTER TASK
## Jenkins + Nexus + Docker + Kubernetes(kind) CI/CD Training Lab

You are acting as a senior DevOps / Platform Engineer.

Your goal is to create a fully working, reproducible, training-ready CI/CD lab from scratch.

This is NOT a skeleton-generation task.

You must actually:
- implement the files,
- build the environment,
- start the services,
- run the pipelines,
- inspect failures,
- fix root causes,
- rerun tests,
- and continue until the acceptance criteria pass.

Do not stop after generating configuration files.

---

# 1. GitHub target

GitHub owner:

```text
hakanbayraktar
```

Target public repository:

```text
hakanbayraktar/jenkins-ci-cd-lab
```

Main branch:

```text
main
```

First inspect authentication:

```bash
gh auth status
```

If the repository does not exist and GitHub CLI is authenticated, create it as public.

If it already exists:
- do not create another repository,
- do not destroy unrelated user work,
- inspect existing contents first,
- preserve useful existing work.

All lab source code, Jenkins pipelines, JCasC, Job DSL, Kubernetes manifests, scripts and documentation must live in this repository.

---

# 2. Required architecture

Build this real flow:

```text
PUBLIC GITHUB REPOSITORY
          |
          v
+-------------------------+
| Jenkins LTS             |
| JCasC + Job DSL         |
| Pipeline as Code        |
+------------+------------+
             |
             | CI
             v
        Git Checkout
             |
          Tests
             |
        Docker Build
             |
         Trivy Scan
             |
             v
+-------------------------+
| Nexus Repository        |
| Docker Hosted Registry  |
+------------+------------+
             |
             | CI SUCCESS ONLY
             v
     Trigger CD Pipeline
             |
             v
 Pull exact immutable tag
       from Nexus
             |
             v
+-------------------------+
| Kubernetes kind cluster |
+------------+------------+
             |
      rollout status
             |
        smoke test
             |
          SUCCESS
```

Critical rule:

```text
If CI fails, CD MUST NOT start.
```

CD must deploy the exact image produced by CI.

Never rebuild the application image during CD.

Apply:

```text
Build Once, Deploy Many
```

---

# 3. Jenkins design

Do NOT require publishing a personal Jenkins image to Docker Hub.

Preferred design:

```text
official Jenkins LTS
        +
small local Dockerfile
        +
plugins.txt
        +
Jenkins Configuration as Code
        +
Job DSL
```

The local Jenkins image may add only what is required for this lab, such as:
- Jenkins plugins
- Docker CLI
- kubectl
- curl
- jq
- other small required CLIs

Build it locally with Docker Compose.

Do not publish it.

Jenkins must be configured automatically.

No manual Jenkins UI setup should be required for:
- admin user
- credentials
- jobs
- pipeline definitions
- Jenkins URL
- basic security
- global environment
- required configuration

Use:
- Jenkins Configuration as Code (JCasC)
- Job DSL
- Pipeline as Code

---

# 4. Versions policy

Before implementation, verify CURRENT stable / LTS versions from OFFICIAL project sources.

Do not blindly use `latest`.

Pin compatible versions.

Reference date for this task:

```text
2026-08-25
```

Known reference values may include:
- Jenkins LTS 2.568.2 / JDK 21
- Nexus Repository 3.94.1
- kind v0.32.0
- kind tested Kubernetes node image around v1.36.1

These are REFERENCE VALUES ONLY.

You MUST verify official current stable/LTS values before finalizing.

Prefer a kind-tested Kubernetes node image rather than forcing a newer unsupported Kubernetes image.

Pin kind node image with the official digest when possible.

Create:

```text
versions.env
docs/VERSIONS.md
```

VERSIONS.md must contain:
- component
- selected version
- reason
- official source
- verification date

Also pin compatible versions for:
- docker:dind
- Trivy
- Jenkins plugins
- kubectl where appropriate

---

# 5. Docker Compose services

Use Docker Compose V2.

Compose project name:

```text
jenkins-ci-cd-lab
```

Minimum services:

```text
jenkins
jenkins-docker
nexus
```

Use a named network:

```text
lab-net
```

The kind cluster will also create its own Docker network:

```text
kind
```

Attach services to networks as required so:
- Jenkins/DIND can access Nexus registry
- kind nodes can access Nexus registry
- Jenkins can access the Kubernetes API using a generated kubeconfig

---

# 6. Docker-in-Docker approach

Prefer a dedicated Docker daemon sidecar instead of mounting the host Docker socket directly into Jenkins.

Preferred model:

```text
Jenkins
   |
DOCKER_HOST
   |
   v
docker:dind
```

Use TLS between Jenkins and DIND when practical.

Typical environment:

```text
DOCKER_HOST=tcp://jenkins-docker:2376
DOCKER_TLS_VERIFY=1
DOCKER_CERT_PATH=/certs/client
```

The DIND daemon may require:

```text
privileged: true
```

Because Nexus Docker registry is local lab infrastructure, HTTP/insecure registry support may be configured ONLY for the isolated DIND daemon and kind nodes.

Do not modify the user's global host Docker daemon unless absolutely required.

Document clearly that this is a training-only design.

---

# 7. Nexus

Expose:

```text
Nexus UI       : http://localhost:8081
Docker Registry: localhost:8082
```

Inside Docker networking use:

```text
http://nexus:8081
nexus:8082
```

Create automatically:

```text
docker-hosted
```

Docker connector port:

```text
8082
```

Enable the Docker Bearer Token Realm.

Do not require manual Nexus UI configuration.

Use Nexus REST API bootstrap automation.

Create:

```text
scripts/bootstrap-nexus.sh
```

It must:
1. wait for Nexus readiness using retry/polling,
2. retrieve the initial admin password if needed,
3. set the demo admin password,
4. enable required realms,
5. create docker-hosted repository,
6. create a Jenkins CI service user,
7. create minimum practical permissions/role for the lab,
8. be idempotent.

Rerunning it must not fail simply because objects already exist.

---

# 8. Demo-only credentials

This is a PUBLIC TRAINING repository.

Only intentionally public demo credentials may be committed.

Use a file:

```text
.env.demo
```

Example values:

```text
JENKINS_ADMIN_USER=admin
JENKINS_ADMIN_PASSWORD=JenkinsLab2026!

NEXUS_ADMIN_USER=admin
NEXUS_ADMIN_PASSWORD=NexusAdmin2026!

NEXUS_CI_USER=jenkins-ci
NEXUS_CI_PASSWORD=NexusJenkins2026!

TRIVY_ENFORCE=false
```

At setup time:

```text
.env.demo -> .env
```

may be copied.

`.env` MUST be in `.gitignore`.

The README must clearly state:

```text
WARNING:
These credentials are intentionally public and exist only
for the isolated training lab.
Never reuse them in production.
```

Do NOT commit:
- personal passwords
- personal GitHub tokens
- personal Docker Hub tokens
- real cloud credentials
- production kubeconfig files

---

# 9. Jenkins credentials

Create Nexus credentials through JCasC.

Credential ID:

```text
nexus-docker-credentials
```

Type:

```text
Username / Password
```

Values must come from environment variables:

```text
${NEXUS_CI_USER}
${NEXUS_CI_PASSWORD}
```

Do not hardcode the password directly inside Jenkinsfile.

Use:

```groovy
withCredentials(...)
```

Docker login should use `--password-stdin`.

Never echo secrets into console logs.

---

# 10. Jenkins JCasC

Create:

```text
jenkins/casc/jenkins.yaml
```

Configure at minimum:
- setup wizard disabled
- admin account
- authentication
- authorization
- Jenkins URL
- executors
- global environment if needed
- Nexus credential
- Job DSL bootstrap

Keep Jenkins security enabled.

Do not enable anonymous administration.

---

# 11. Jenkins plugins

Create:

```text
jenkins/plugins.txt
```

Use only required plugins.

Likely examples:
- configuration-as-code
- job-dsl
- workflow-aggregator
- git
- credentials
- credentials-binding
- pipeline-stage-view
- timestamper
- ws-cleanup
- docker-workflow

Verify compatibility with the chosen Jenkins LTS.

Pin versions in a maintainable way.

Jenkins must start without plugin dependency failures.

---

# 12. Job DSL

Create:

```text
jenkins/job-dsl/jobs.groovy
```

Automatically create these jobs:

```text
flask-app-ci
flask-app-cd
```

Both must load pipeline definitions from the public GitHub repository:

```text
https://github.com/hakanbayraktar/jenkins-ci-cd-lab.git
```

CI Jenkinsfile:

```text
jenkins/pipelines/Jenkinsfile.ci
```

CD Jenkinsfile:

```text
jenkins/pipelines/Jenkinsfile.cd
```

Because the GitHub repository is public, SCM credentials should not be required.

Local Jenkins is not internet-accessible from GitHub, so GitHub webhook is not mandatory.

Support:
- manual Jenkins trigger
- `make demo`
- optional SCM polling

Document that production would normally use GitHub webhook.

---

# 13. Flask application

Create a simple but useful training application.

Structure:

```text
app/
├── app.py
├── requirements.txt
├── requirements-dev.txt
├── tests/
│   └── test_app.py
└── Dockerfile
```

Endpoints:

```text
GET /
GET /health
GET /version
```

`GET /` example:

```json
{
  "application": "jenkins-ci-cd-lab",
  "message": "CI/CD pipeline is working"
}
```

`GET /health`:

```json
{
  "status": "healthy"
}
```

HTTP 200.

`GET /version` should expose:
- deployed image/application version
- training environment

Example:

```json
{
  "version": "abc1234",
  "environment": "training"
}
```

Pass the version through Kubernetes environment variables.

---

# 14. Flask tests

Use pytest.

Test at minimum:
- /
- /health
- /version

Required behavior:

```text
If tests fail:
- no production image push to Nexus
- no CD trigger
```

This must also be demonstrated in the student failure lab.

---

# 15. Application Dockerfile

Create a professional teaching example.

Prefer:
- multi-stage build
- test stage
- runtime stage
- non-root runtime
- small base image
- layer caching
- requirements copied before source
- healthcheck where useful

Logical targets may include:

```text
base
test
runtime
```

CI should be able to run tests using a Docker build target so Jenkins itself does not need Python installed.

---

# 16. CI pipeline

Create:

```text
jenkins/pipelines/Jenkinsfile.ci
```

Stages:

## Checkout
Checkout the public GitHub repository.

## Metadata
Create immutable metadata, such as:
- short Git SHA
- Jenkins build number
- image tag

Example:

```text
12-a84b213
```

Do not deploy based solely on `latest`.

## Unit Tests
Run real Flask tests.

If they fail, stop.

## Docker Build
Build the runtime image.

Preferred internal image reference:

```text
nexus:8082/jenkins-lab/flask-app:${IMAGE_TAG}
```

## Trivy Scan
Run Trivy.

Prefer running Trivy as a pinned container image.

Archive:

```text
trivy-report.txt
```

Default lab behavior:

```text
TRIVY_ENFORCE=false
```

If enabled, HIGH/CRITICAL findings may fail the pipeline.

## Nexus Login
Use Jenkins credentials.

## Push Image
Push the immutable image tag.

Optionally push `latest` for demonstration, but Kubernetes deployment MUST use the immutable tag.

## Trigger CD
Only if every prior CI stage succeeded.

Trigger:

```text
flask-app-cd
```

Pass:

```text
IMAGE_TAG
```

or an exact `IMAGE_REF`.

---

# 17. CD pipeline

Create:

```text
jenkins/pipelines/Jenkinsfile.cd
```

It must be parameterized.

Required parameter:

```text
IMAGE_TAG
```

Reject blank values.

Stages:

## Validate Parameters
Validate the immutable tag.

## Verify Nexus Artifact
Pull the exact image:

```bash
docker pull nexus:8082/jenkins-lab/flask-app:${IMAGE_TAG}
```

This proves the artifact exists in Nexus.

Do NOT rebuild it.

## Deploy to Kubernetes
Deploy that exact image tag.

## Rollout Status
Example:

```bash
kubectl rollout status deployment/flask-app \
  -n jenkins-lab \
  --timeout=120s
```

## Smoke Test
Verify:
- `/health` returns HTTP 200
- `/version` matches the expected IMAGE_TAG/version

---

# 18. Rollback

If deployment or smoke test fails:

```bash
kubectl rollout undo deployment/flask-app -n jenkins-lab
```

Then check rollout status again.

Handle the first-deployment/no-previous-revision case cleanly.

Do not report a failed deployment as successful.

Make pipeline output easy to teach from.

---

# 19. Kubernetes manifests

Directory:

```text
k8s/
```

Create at minimum:

```text
namespace.yaml
deployment.yaml
service.yaml
```

Namespace:

```text
jenkins-lab
```

Deployment:

```text
flask-app
```

Service:

```text
flask-app
```

Use:
- 2 replicas
- readinessProbe
- livenessProbe
- resource requests
- resource limits
- imagePullSecrets

Reasonable lab resources:

```yaml
requests:
  cpu: 50m
  memory: 64Mi

limits:
  cpu: 250m
  memory: 256Mi
```

Expose application with NodePort:

```text
30080
```

Map host port:

```text
8088
```

Final application URL:

```text
http://localhost:8088
```

---

# 20. kind cluster

Cluster name:

```text
jenkins-ci-cd-lab
```

Prefer:

```text
1 control-plane
1 worker
```

Create:

```text
kind/kind-config.yaml
```

Target a laptop/workstation with approximately 16 GB RAM.

Use a kind-tested Kubernetes node image and pin digest.

Configure required port mapping for application access.

---

# 21. Nexus registry access from kind

kind nodes must be able to pull:

```text
nexus:8082/jenkins-lab/flask-app:${IMAGE_TAG}
```

Configure current containerd registry mechanism.

Prefer the current `certs.d/hosts.toml` style if appropriate for the selected kind/containerd release.

Do not rely on deprecated registry configuration blindly.

Typical target path may resemble:

```text
/etc/containerd/certs.d/nexus:8082/hosts.toml
```

Registry endpoint:

```text
http://nexus:8082
```

Test the registry pull for real.

---

# 22. Kubernetes imagePullSecret

Create at setup time:

```text
nexus-regcred
```

in namespace:

```text
jenkins-lab
```

Using demo Nexus CI credentials.

Do NOT commit the generated secret manifest.

Create it dynamically during setup.

---

# 23. Jenkins Kubernetes access

Jenkins must be able to run:

```bash
kubectl get nodes
```

against the kind cluster.

Generate a Jenkins-specific kubeconfig under an ignored directory such as:

```text
generated/jenkins-kubeconfig
```

Mount it read-only into Jenkins.

Because Jenkins runs in Docker, rewrite the API server address if needed so it uses a resolvable kind control-plane hostname instead of host-loopback.

Do not disable TLS verification.

If necessary, configure the kind API server certificate SANs correctly.

Actually test cluster access from the Jenkins container.

---

# 24. Single-command setup

Primary user flow:

```bash
git clone https://github.com/hakanbayraktar/jenkins-ci-cd-lab.git
cd jenkins-ci-cd-lab
make up
```

`make up` must:

1. run prerequisite checks,
2. create `.env` from `.env.demo` if needed,
3. create required Docker network state,
4. create/reuse the kind cluster,
5. start Jenkins, DIND and Nexus,
6. wait for Nexus readiness,
7. bootstrap Nexus,
8. create Docker hosted repository,
9. create Nexus CI user/role,
10. create Kubernetes namespace,
11. configure kind registry access,
12. create imagePullSecret,
13. generate Jenkins kubeconfig,
14. wait for Jenkins readiness,
15. verify JCasC loaded,
16. verify Job DSL jobs exist,
17. print URLs and demo credentials.

Use polling/retry.

Do NOT use crude fixed waits like:

```bash
sleep 60
```

unless there is no practical alternative.

---

# 25. Makefile

Create at minimum:

```text
make help
make doctor
make up
make demo
make verify
make status
make logs
make down
make reset
```

Semantics:

## make doctor
Check prerequisites and ports.

## make up
Idempotently create/start the lab.

## make demo
Trigger real Jenkins CI and wait for automatic CD completion.

## make verify
Run automated acceptance checks.

## make status
Show Jenkins, Nexus, kind and application state.

## make logs
Make useful service logs easy to inspect.

## make down
Stop/remove runtime resources while preserving persistent data when practical.

## make reset
Remove ONLY lab-owned:
- kind cluster
- compose containers
- Jenkins data
- Nexus data
- lab volumes/networks
- generated local files

Never delete unrelated user resources.

---

# 26. Scripts

Recommended structure:

```text
scripts/
├── setup.sh
├── doctor.sh
├── bootstrap-nexus.sh
├── configure-kind-registry.sh
├── generate-jenkins-kubeconfig.sh
├── create-k8s-secret.sh
├── trigger-demo.sh
├── verify.sh
├── status.sh
├── teardown.sh
├── reset.sh
├── install-prerequisites-ubuntu.sh
└── lib/
    └── common.sh
```

Shell standard:

```bash
set -Eeuo pipefail
```

Create reusable helpers:
- log
- warn
- die
- retry
- wait_for_http
- command_exists

Respect `NO_COLOR` when practical.

---

# 27. Port checks

Before starting, verify:

```text
8080 Jenkins
8081 Nexus UI
8082 Nexus Docker Registry
8088 Flask Application
```

If a port is occupied, produce a clear error.

Do not silently kill unrelated processes.

---

# 28. Health checks

Add Docker Compose healthchecks where useful.

Verify:
- Jenkins HTTP readiness
- Nexus REST readiness
- DIND `docker info`
- kind nodes Ready
- application `/health`

---

# 29. README

Create a professional, instructor-friendly README.

Required sections:

```text
Overview
Architecture
Technologies
Prerequisites
Quick Start
URLs
Demo Credentials
How CI Works
How CD Works
Pipeline Flow
Lab Exercises
Useful Commands
Troubleshooting
Cleanup
Security Notes
Production Differences
Possible Extensions
```

Use Mermaid for architecture.

Students should be able to run the lab without an instructor sitting next to them.

---

# 30. Demo credentials table

README must show a visible table such as:

| Service | URL | Username | Password |
|---|---|---|---|
| Jenkins | http://localhost:8080 | admin | JenkinsLab2026! |
| Nexus | http://localhost:8081 | admin | NexusAdmin2026! |
| Nexus CI User | localhost:8082 | jenkins-ci | NexusJenkins2026! |
| Flask App | http://localhost:8088 | - | - |

Mark this section:

```text
TRAINING ONLY
```

---

# 31. Documentation

Create:

```text
docs/architecture.md
docs/student-lab.md
docs/instructor-guide.md
docs/troubleshooting.md
docs/VERSIONS.md
```

## student-lab.md

Guide students through:

1. inspect architecture,
2. inspect Dockerfile,
3. inspect Flask tests,
4. run CI,
5. observe Jenkins stages,
6. inspect Nexus image,
7. observe automatic CD trigger,
8. inspect Kubernetes deployment,
9. access application,
10. change source,
11. redeploy,
12. inspect rollout history.

---

# 32. Failure exercises

Include two intentional training exercises.

## Failure Lab 1 — CI failure

Student deliberately breaks a unit test.

Expected:

```text
CI FAIL
No production image push
CD does not start
```

## Failure Lab 2 — CD failure / rollback

Student temporarily breaks readiness/deployment configuration.

Expected:

```text
CI SUCCESS
CD START
rollout FAIL
rollback attempted
```

Document recovery steps.

---

# 33. Lab vs Production section

Explain clearly.

Lab design may use:

```text
Docker Compose
Docker DIND
demo credentials
Nexus HTTP registry
single-host kind
Jenkins controller performing work
```

Production would normally use:

```text
TLS everywhere
secret manager
dedicated Jenkins agents
production Kubernetes
HA artifact registry
RBAC
webhooks
OIDC/service identities
backups
monitoring
audit
```

Make clear WHY the training environment is intentionally simplified.

---

# 34. Optional extensions

Do NOT bloat the default lab with:
- SonarQube
- Prometheus
- Grafana
- ELK
- Argo CD

The main learning goals are:

```text
Docker
Jenkins
CI/CD
Nexus
Kubernetes
```

Trivy is allowed in the base lab because it fits naturally into the CI pipeline.

List heavier tools only as optional extensions.

---

# 35. Expected repository structure

Target something close to:

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

Ignore generated runtime files.

---

# 36. Supported host targets

Primary target:

```text
Ubuntu Linux
```

Also support where practical:

```text
macOS + Docker Desktop
```

Prerequisites:

```text
Docker
Docker Compose V2
kubectl
kind
git
curl
jq
make
```

`make doctor` must detect missing prerequisites.

`make up` must NOT silently install OS packages.

An optional Ubuntu installer script may be provided.

---

# 37. Idempotency

These must be safe:

```bash
make up
make up
```

Nexus bootstrap must be repeatable.

Do not recreate existing kind cluster unnecessarily.

Do not fail just because repository/user/realm already exists.

---

# 38. Verification script

Create:

```text
scripts/verify.sh
```

It must validate:

## Docker
```text
docker info
docker compose ps
```

## kind
```text
kind get clusters
kubectl get nodes
```

Expect control-plane and worker Ready.

## Nexus
Verify:
- HTTP ready
- docker-hosted exists
- jenkins-ci user exists

## Jenkins
Verify:
- HTTP accessible
- JCasC loaded
- flask-app-ci exists
- flask-app-cd exists

## Kubernetes
After deployment verify:
- namespace exists
- deployment exists
- pods Ready
- service exists

## Application
Verify:

```text
GET http://localhost:8088/health
```

returns HTTP 200.

Verify `/version` matches the deployed immutable tag.

---

# 39. Real end-to-end demo

`make demo` must trigger a REAL Jenkins CI build.

Poll Jenkins REST API until completion.

CI success must automatically cause CD to start.

Poll CD until completion.

Then verify:

```text
http://localhost:8088/health
http://localhost:8088/version
```

Print a clear result, for example:

```text
==================================================
 Jenkins CI/CD Lab - Demo Result
==================================================

Jenkins CI .............. SUCCESS
Docker Build ............ SUCCESS
Trivy Scan .............. SUCCESS
Nexus Push .............. SUCCESS
CD Trigger .............. SUCCESS
Kubernetes Deployment ... SUCCESS
Smoke Test .............. SUCCESS

Application:
http://localhost:8088

Version:
a84b213

LAB STATUS: PASS
==================================================
```

---

# 40. TEST / FIX LOOP — MANDATORY

Do NOT stop at the first error.

Use this loop:

```text
PLAN
  ↓
IMPLEMENT
  ↓
BUILD
  ↓
START LAB
  ↓
VERIFY
  ↓
RUN CI
  ↓
RUN CD
  ↓
TEST APPLICATION
  ↓
PASS?
 /    \
NO     YES
|       |
DEBUG   FINAL REVIEW
|
FIX
|
RETEST
└───────────────> LOOP
```

If Jenkins fails:
- inspect `docker compose logs jenkins`
- inspect plugin compatibility
- inspect JCasC schema/config
- inspect Job DSL errors

If Nexus fails:
- inspect `docker compose logs nexus`
- inspect REST request/response
- verify realms/repository/user configuration

If Kubernetes fails:
- `kubectl get all -A`
- `kubectl describe`
- `kubectl logs`
- `kubectl get events -A --sort-by=.lastTimestamp`

If registry fails:
- test Docker login/pull/push separately
- test DNS/network reachability
- test kind node registry configuration
- test imagePullSecret

If pipeline fails:
- inspect Jenkins console logs
- identify root cause
- make the smallest correct fix
- rerun

Do not make random changes without reading the actual error.

---

# 41. Loop termination

Do not say TASK COMPLETE until all acceptance criteria pass.

If there is a genuine external blocker such as:
- no GitHub authentication
- no Docker daemon
- no Internet access for dependency pulls
- missing permission outside the repository

then:
1. identify the exact blocker,
2. show the failing command,
3. summarize relevant logs,
4. finish every test that is still possible,
5. leave the repository in the best possible state.

Do not stop for ordinary coding/configuration bugs.

---

# 42. Acceptance criteria

The full checklist is also provided in `ACCEPTANCE_CHECKLIST.md`.

All must pass before declaring success.

Core criteria include:

```text
make doctor            PASS
make up                PASS
Jenkins UI             reachable
Jenkins setup wizard   disabled
Jenkins login          works
flask-app-ci           auto-created
flask-app-cd           auto-created
Nexus UI               reachable
docker-hosted          exists
jenkins-ci Nexus user  exists
kind nodes             Ready
Jenkins -> Kubernetes  works
CI tests               really run
Docker build           really runs
Nexus push             really runs
CI -> CD trigger       automatic
CD exact image pull    works
Kubernetes deployment  works
2 replicas             Ready
/health                HTTP 200
/version               exact deployed version
CI failure             blocks CD
CD failure             attempts rollback
make verify            PASS
make demo              PASS
reset/recreate          works
```

---

# 43. Git workflow

Use sensible commits such as:

```text
feat: add flask demo application
feat: add kind lab cluster
feat: automate nexus bootstrap
feat: configure jenkins with jcasc and job dsl
feat: add ci pipeline
feat: add cd kubernetes deployment
test: add end-to-end lab verification
docs: add student and instructor lab guides
```

Do not commit runtime-generated sensitive files.

Before final push:

```bash
git status
git diff
```

Repository should end clean.

---

# 44. Final report

After everything passes, report:

```text
Repository:
https://github.com/hakanbayraktar/jenkins-ci-cd-lab

Versions:
Jenkins:
Nexus:
kind:
Kubernetes:
Docker:
Trivy:

Services:
Jenkins ........ PASS
Nexus .......... PASS
Docker Registry  PASS
kind ........... PASS
CI Pipeline .... PASS
CD Pipeline .... PASS
Application .... PASS

Tested Flow:
GitHub
 -> Jenkins CI
 -> Docker Build
 -> Trivy
 -> Nexus Push
 -> Jenkins CD
 -> Nexus Pull
 -> Kubernetes Deploy
 -> Rollout
 -> Smoke Test

Demo URLs:
Jenkins:
Nexus:
Application:

Demo Credentials:
...

Final Verification:
make verify .... PASS
make demo ...... PASS
```

List important generated files.

---

# 45. Non-negotiable rules

NEVER:
- stop after generating a skeleton
- claim it works without running it
- use `latest` blindly
- commit real credentials
- trigger CD after failed CI
- rebuild the application in CD
- deploy Kubernetes using only `latest`
- leave Nexus setup manual
- leave Jenkins jobs manual
- stop at the first ordinary error

ALWAYS:
- use JCasC
- use Job DSL
- use Pipeline as Code
- automate Nexus bootstrap
- use immutable image tags
- follow Build Once / Deploy Many
- run health checks
- run smoke tests
- implement rollback logic
- make setup idempotent
- verify end-to-end
- provide troubleshooting docs
- provide student lab guide
- provide instructor guide

---

# 46. Start now

Inspect the current folder first.

Produce a short implementation plan.

Then implement immediately.

Do not ask for approval for each small step.

Create the files.
Start the lab.
Run the pipelines.
Read the errors.
Fix them.
Retest.

Continue the implement -> test -> debug -> fix -> retest loop until the lab is genuinely working.
