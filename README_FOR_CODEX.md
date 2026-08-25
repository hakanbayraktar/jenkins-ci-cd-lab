# START HERE — Codex Instructions

This ZIP is a task package for building a complete local Jenkins CI/CD training lab.

## What to do

1. Extract this ZIP into the directory where Codex is running.
2. Give Codex `CODEX_TASK.md` as the main task.
3. Codex must create or update the target Git repository:
   `hakanbayraktar/jenkins-ci-cd-lab`
4. Codex must actually run and test the lab locally.
5. Do not accept a result that only contains generated files without passing the verification loop.

## Primary target

A local/Ubuntu lab containing:

- Jenkins LTS
- Jenkins Configuration as Code
- Job DSL
- Docker-in-Docker sidecar
- Nexus Repository Docker hosted registry
- Flask demo application
- Docker build
- pytest
- Trivy
- CI pipeline
- automatic CI -> CD trigger
- kind Kubernetes cluster
- immutable image deploy
- rollout verification
- smoke test
- rollback behavior
- one-command setup
- student documentation
- instructor documentation

## Desired user experience

```bash
git clone https://github.com/hakanbayraktar/jenkins-ci-cd-lab.git
cd jenkins-ci-cd-lab
make up
make demo
make verify
```

## Important

The demo credentials are intentionally public training credentials.

No real personal secrets may be committed.

Codex must verify current stable/LTS versions from official sources before finalizing pinned component versions.

Read these files in order:

1. `CODEX_TASK.md`
2. `ACCEPTANCE_CHECKLIST.md`
3. `REPO_TARGET_STRUCTURE.md`
4. `VERSION_POLICY.md`

Do not declare success until the acceptance checklist passes.
