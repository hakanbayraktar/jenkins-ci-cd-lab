# Student lab

1. Read `app/Dockerfile`, `app/tests/test_app.py`, JCasC and both Jenkinsfiles.
2. Run `make up`, then open Jenkins and Nexus.
3. Run `make demo`; observe Checkout, Tests, Build, Trivy, Nexus Push, and the automatic CD run.
4. Inspect Nexus `docker-hosted`, then `kubectl -n jenkins-lab get pods` and `curl http://localhost:8088/version`.
5. Change application source, commit/push to the configured public repository, and run another demo. Compare rollout history.

CI failure exercise: make a test assertion fail, run CI, confirm no new registry tag and no CD build; restore it. CD rollback exercise: temporarily make readiness use `/broken`, run CI, observe CD failure/rollback, restore it, and run a healthy deployment.
