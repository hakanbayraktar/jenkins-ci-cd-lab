# Jenkins CI/CD Lab — Codex Task Pack

## Entry point

Codex should start with:

```text
AGENTS.md
```

`AGENTS.md` defines the execution rules, test/fix loop, security constraints,
completion gate, and the required reading order.

Then read:

1. `START_HERE.md`
2. `CODEX_TASK.md`
3. `ACCEPTANCE_CHECKLIST.md`
4. `REPO_TARGET_STRUCTURE.md`
5. `VERSION_POLICY.md`

## Target

Build and validate:

```text
hakanbayraktar/jenkins-ci-cd-lab
```

## Required final command flow

```bash
make doctor
make up
make demo
make verify
```

Codex must keep debugging until the acceptance checklist passes.

Do not accept a result that only generates files without actually running and
testing the Jenkins -> Nexus -> Kubernetes CI/CD flow.
