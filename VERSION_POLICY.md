# Version Selection Policy

Codex must verify versions from official project sources at implementation time.

Reference date:

```text
2026-08-25
```

Reference values from the task discussion:

```text
Jenkins LTS       2.568.2
Java              JDK 21
Nexus Repository  3.94.1
kind              v0.32.0
Kubernetes image  kind-tested v1.36.1 line
```

These values are NOT permission to skip verification.

## Rules

1. Prefer stable/LTS.
2. Avoid blind `latest`.
3. Pin versions used by the lab.
4. Prefer versions officially tested together.
5. For kind, prefer a node image published/tested by that kind release.
6. Pin kind node digest when official release notes provide it.
7. Verify Jenkins plugin compatibility with the selected Jenkins LTS.
8. Keep the lab reproducible.
9. Record decisions in `docs/VERSIONS.md`.
10. If the newest release causes incompatibility, choose the newest compatible stable release and document why.

## Sources to prioritize

- Jenkins official download / Docker documentation / plugin metadata
- Sonatype Nexus Repository official image/release documentation
- kind official GitHub releases
- Kubernetes official release documentation
- Aqua Trivy official releases
- Docker official image/release documentation

Do not use random blogs as the authority for pinned versions.
