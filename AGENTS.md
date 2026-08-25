# AGENTS.md

## Mission

Build and fully validate the training project defined in this repository task pack.

The target project is:

```text
hakanbayraktar/jenkins-ci-cd-lab
```

This is a hands-on DevOps training lab containing:

- Jenkins LTS
- Jenkins Configuration as Code (JCasC)
- Job DSL
- Pipeline as Code
- Docker / Docker-in-Docker
- Nexus Repository Docker registry
- Python Flask demo application
- pytest
- Trivy
- CI pipeline
- automatic CI -> CD trigger
- Kubernetes kind cluster
- immutable image deployment
- rollout validation
- smoke testing
- rollback behavior
- automated setup and verification

## Required reading order

Before changing code, read these files completely:

1. `START_HERE.md`
2. `CODEX_TASK.md`
3. `ACCEPTANCE_CHECKLIST.md`
4. `REPO_TARGET_STRUCTURE.md`
5. `VERSION_POLICY.md`

Treat `CODEX_TASK.md` as the primary specification.

Treat `ACCEPTANCE_CHECKLIST.md` as the completion gate.

If instructions appear to conflict, use this priority:

1. `AGENTS.md`
2. `CODEX_TASK.md`
3. `ACCEPTANCE_CHECKLIST.md`
4. `VERSION_POLICY.md`
5. `REPO_TARGET_STRUCTURE.md`
6. existing repository conventions

## Working style

Do not ask for approval after every small implementation step.

Work autonomously through:

```text
inspect
-> plan
-> implement
-> build
-> start
-> test
-> inspect logs
-> identify root cause
-> fix
-> retest
-> repeat
```

Do not stop at the first ordinary error.

Do not declare success after only generating files.

The lab must be executed and validated.

## Mandatory completion loop

Continue until all feasible acceptance criteria pass.

At minimum, success requires:

```bash
make doctor
make up
make demo
make verify
```

to succeed in the target environment.

If one fails:

1. read the real error,
2. inspect relevant logs,
3. identify root cause,
4. apply the smallest correct fix,
5. rerun the failed step,
6. rerun dependent acceptance checks.

Examples:

### Jenkins

Inspect:

```bash
docker compose logs jenkins
```

Check:
- plugin compatibility
- JCasC syntax/schema
- Job DSL
- credentials
- pipeline definitions

### Nexus

Inspect:

```bash
docker compose logs nexus
```

Check:
- readiness
- REST API responses
- realms
- Docker hosted repository
- users/roles
- registry authentication

### Docker / DIND

Check:

```bash
docker info
docker compose ps
docker login
docker pull
docker push
```

### Kubernetes / kind

Check:

```bash
kind get clusters
kubectl get nodes
kubectl get all -A
kubectl describe ...
kubectl logs ...
kubectl get events -A --sort-by=.lastTimestamp
```

Check:
- containerd registry configuration
- Nexus DNS/network reachability
- imagePullSecrets
- kubeconfig
- rollout status
- health probes

### Jenkins pipelines

Read Jenkins console output.

Never make random configuration changes without first reading the actual failure.

## GitHub behavior

GitHub owner:

```text
hakanbayraktar
```

Target public repository:

```text
hakanbayraktar/jenkins-ci-cd-lab
```

Before repository operations:

```bash
gh auth status
```

If the repository does not exist and authentication permits it, create it.

If it already exists:
- inspect it first,
- preserve useful work,
- do not delete unrelated content blindly.

Use `main` as the primary branch unless the existing repository clearly requires otherwise.

Use sensible commits.

Do not push known broken final state and call the task complete.

## Security rules

This is a public training lab.

Only intentionally public demo credentials may be committed.

Never commit:
- real personal credentials
- GitHub personal access tokens
- Docker Hub personal credentials
- cloud access keys
- production kubeconfig
- private SSH keys
- real secrets

`.env` must be ignored.

Generated kubeconfig must be ignored.

Jenkins/Nexus runtime data must not be committed.

Demo credentials must be clearly marked:

```text
TRAINING ONLY
```

## Architecture rules

Do not require a personal Jenkins image published to Docker Hub.

Prefer:

```text
official Jenkins LTS
+ local Dockerfile
+ plugins.txt
+ JCasC
+ Job DSL
```

Jenkins must come up automatically configured.

Do not require manual UI configuration for:
- Jenkins jobs
- Nexus credentials
- Jenkins admin
- pipeline definitions

Nexus must also be bootstrapped automatically through REST API.

## CI rules

CI must perform the real flow:

```text
Git checkout
-> tests
-> Docker build
-> Trivy scan
-> Nexus login
-> immutable image push
-> trigger CD only on success
```

If CI fails:

```text
CD MUST NOT START
```

Use immutable image tags.

Do not rely only on `latest`.

## CD rules

CD must:

```text
receive IMAGE_TAG
-> verify/pull exact Nexus artifact
-> deploy exact same artifact
-> wait for rollout
-> smoke test
-> verify version
```

Do not rebuild the application image in CD.

Follow:

```text
Build Once, Deploy Many
```

If deployment/smoke test fails, attempt rollback and report the failure correctly.

## Version rules

Before finalizing, verify current compatible stable/LTS versions from official sources.

Reference date:

```text
2026-08-25
```

Do not use `latest` blindly.

Prefer reproducible pinned versions.

For kind, prefer an officially tested Kubernetes node image for the selected kind version, ideally pinned by digest.

Document selected versions in:

```text
versions.env
docs/VERSIONS.md
```

## Scope control

The default lab should focus on:

```text
Docker
Jenkins
CI/CD
Nexus
Kubernetes
```

Trivy belongs in the base CI pipeline.

Do not add heavy optional platforms such as:
- SonarQube
- Prometheus
- Grafana
- ELK
- Argo CD

unless required to fix a core task or explicitly requested later.

List them only as possible extensions.

## Documentation requirements

The final project must include usable documentation for both students and instructor.

Required:

```text
README.md
docs/architecture.md
docs/student-lab.md
docs/instructor-guide.md
docs/troubleshooting.md
docs/VERSIONS.md
```

Document:
- quick start
- URLs
- demo credentials
- architecture
- CI flow
- CD flow
- failure exercises
- rollback
- troubleshooting
- cleanup
- lab vs production differences

## Acceptance gate

Before declaring completion, open `ACCEPTANCE_CHECKLIST.md` and verify each item.

Do not declare completion merely because code looks correct.

The strongest evidence is real execution.

Final gate:

```text
make verify = PASS
make demo   = PASS
```

and the actual flow must be proven:

```text
GitHub
-> Jenkins CI
-> tests
-> Docker build
-> Trivy
-> Nexus push
-> Jenkins CD
-> Nexus exact image pull
-> kind Kubernetes deploy
-> rollout
-> smoke test
```

## External blockers

If blocked by something genuinely outside the repository, such as:
- Docker daemon unavailable
- GitHub authentication unavailable
- Internet access unavailable
- external permission denied

do not pretend success.

Instead:
1. show the exact failing command,
2. summarize the relevant error,
3. complete every other feasible part,
4. leave the code in the best validated state possible.

Ordinary coding, configuration, networking, pipeline, Docker, Nexus, Jenkins or Kubernetes errors are not reasons to stop. Debug and fix them.

## Final response format

When finished, provide a concise technical report:

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
Jenkins ........ PASS/FAIL
Nexus .......... PASS/FAIL
Docker Registry  PASS/FAIL
kind ........... PASS/FAIL
CI Pipeline .... PASS/FAIL
CD Pipeline .... PASS/FAIL
Application .... PASS/FAIL

Final Verification:
make verify .... PASS/FAIL
make demo ...... PASS/FAIL
```

Include:
- important files created,
- any remaining genuine external blockers,
- exact final URLs,
- demo credentials reminder,
- confirmation that no real secrets were committed.
