# Selected versions

Verified 2026-08-25 from official project sources.

| Component | Selected version | Reason / official source |
|---|---:|---|
| Jenkins | 2.568.2 LTS, JDK 21 image | Current LTS selected for predictable plugin support: [Jenkins downloads](https://www.jenkins.io/download/) |
| Nexus Repository CE | 3.94.1 | Pinned official Sonatype image tag: [Sonatype Docker Hub](https://hub.docker.com/r/sonatype/nexus3/tags) |
| kind | v0.32.0 | Official release used by the host: [kind release](https://github.com/kubernetes-sigs/kind/releases/tag/v0.32.0) |
| Kubernetes node | v1.36.1, sha256:3489…f7ebd5 | Exact image officially tested by kind v0.32.0: [kind release](https://github.com/kubernetes-sigs/kind/releases/tag/v0.32.0) |
| kubectl | v1.36.1 | Matches the kind node minor: [Kubernetes releases](https://kubernetes.io/releases/) |
| Docker DIND | 28.5.2-dind | Pinned Docker daemon image for the isolated sidecar: [Docker Hub](https://hub.docker.com/_/docker) |
| Trivy | 0.68.2 | Pinned Aqua Security image: [Trivy container package](https://github.com/aquasecurity/trivy/pkgs/container/trivy/614284620?tag=0.68.2) |
| Python | 3.13.2-alpine3.21 | Pinned small runtime base: [Python Docker image](https://hub.docker.com/_/python) |

No `latest` tag is used. Image digests should be refreshed as a deliberate maintenance action after retesting the full flow.
