# Acceptance Checklist

Codex must mark every item PASS before declaring the lab complete.

## Environment

- [ ] `make doctor` passes.
- [ ] Required ports are checked without killing unrelated processes.
- [ ] `make up` completes successfully.
- [ ] Running `make up` a second time is safe/idempotent.

## Jenkins

- [ ] Jenkins is reachable at `http://localhost:8080`.
- [ ] Setup wizard is disabled.
- [ ] Demo admin login works.
- [ ] JCasC loads successfully.
- [ ] Job DSL executes successfully.
- [ ] `flask-app-ci` exists automatically.
- [ ] `flask-app-cd` exists automatically.
- [ ] Nexus credential exists through JCasC.
- [ ] Jenkins logs show no fatal plugin dependency errors.

## Nexus

- [ ] Nexus is reachable at `http://localhost:8081`.
- [ ] Docker registry is reachable on port `8082`.
- [ ] Docker Bearer Token Realm is enabled.
- [ ] `docker-hosted` repository exists.
- [ ] `jenkins-ci` user exists.
- [ ] Bootstrap can run repeatedly without breaking the lab.
- [ ] Jenkins/DIND can login to Nexus.
- [ ] Jenkins/DIND can push and pull a test image.

## kind / Kubernetes

- [ ] kind cluster `jenkins-ci-cd-lab` exists.
- [ ] Control-plane node is Ready.
- [ ] Worker node is Ready.
- [ ] Jenkins can run `kubectl get nodes`.
- [ ] Namespace `jenkins-lab` exists.
- [ ] `nexus-regcred` exists after setup.
- [ ] kind nodes can reach Nexus.
- [ ] Kubernetes can pull the private Nexus-hosted image.

## Application

- [ ] Flask `/` endpoint works.
- [ ] Flask `/health` returns HTTP 200.
- [ ] Flask `/version` returns deployed version.
- [ ] pytest covers `/`, `/health`, `/version`.
- [ ] Runtime container runs as non-root.
- [ ] Dockerfile uses a clean multi-stage structure.

## CI

- [ ] CI checks out the public GitHub repo.
- [ ] CI generates an immutable image tag.
- [ ] CI runs real tests.
- [ ] CI builds the real runtime image.
- [ ] CI runs Trivy.
- [ ] CI archives Trivy output.
- [ ] CI logs into Nexus with Jenkins credentials.
- [ ] CI pushes the immutable image to Nexus.
- [ ] CI triggers CD only after success.
- [ ] A deliberately failing unit test prevents CD.

## CD

- [ ] CD requires `IMAGE_TAG`.
- [ ] CD pulls the exact Nexus image.
- [ ] CD does not rebuild the image.
- [ ] Kubernetes deploy uses the exact immutable tag.
- [ ] Rollout status is checked.
- [ ] Two replicas become Ready.
- [ ] Smoke test checks `/health`.
- [ ] Smoke test validates `/version`.
- [ ] Deployment failure attempts rollback.
- [ ] First-deployment/no-prior-revision case is handled cleanly.

## User workflow

- [ ] `make status` works.
- [ ] `make logs` works.
- [ ] `make demo` triggers real CI and waits for real CD.
- [ ] `make verify` performs automated end-to-end verification.
- [ ] `make down` is safe.
- [ ] `make reset` removes only lab-owned resources.
- [ ] `make down && make up && make demo` succeeds again.

## Documentation

- [ ] README is usable by students.
- [ ] README contains architecture.
- [ ] README contains URLs.
- [ ] README contains intentionally public demo credentials.
- [ ] README clearly labels demo passwords as TRAINING ONLY.
- [ ] `docs/student-lab.md` exists.
- [ ] `docs/instructor-guide.md` exists.
- [ ] `docs/troubleshooting.md` exists.
- [ ] `docs/architecture.md` exists.
- [ ] `docs/VERSIONS.md` exists.
- [ ] CI failure exercise is documented.
- [ ] CD failure / rollback exercise is documented.
- [ ] Lab-vs-production differences are documented.

## Git hygiene

- [ ] `.env` is ignored.
- [ ] generated kubeconfig is ignored.
- [ ] Jenkins runtime data is not committed.
- [ ] Nexus runtime data is not committed.
- [ ] real personal credentials are not committed.
- [ ] repository is clean after final push.

## Final gate

- [ ] `make verify` = PASS.
- [ ] `make demo` = PASS.
- [ ] CI -> Nexus -> CD -> kind -> smoke test is proven with real execution.
- [ ] Final report contains exact tested versions and URLs.
