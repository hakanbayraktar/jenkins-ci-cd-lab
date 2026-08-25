# Architecture

Jenkins is locally built from the official LTS image. JCasC creates the secured demo administrator, Nexus credential, and two Pipeline-from-SCM jobs through Job DSL. A TLS-enabled DIND sidecar performs all image work. Nexus is attached to both the lab and kind Docker networks so DIND pushes to `nexus:8082` and kind nodes pull the same exact tag.

`make up` creates a one-control-plane/one-worker kind cluster, configures containerd `certs.d/hosts.toml`, creates the private-registry secret, and mounts a generated Jenkins-only kubeconfig read-only. The service is NodePort 30080, mapped by kind to localhost:8088.
