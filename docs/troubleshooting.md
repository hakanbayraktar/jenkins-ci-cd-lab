# Troubleshooting

Run `make doctor` first. A busy 8080/8081/8082/8088 port is reported without killing its owner. For Jenkins inspect `docker compose logs jenkins`; JCasC and plugin failures are startup errors. For Nexus inspect `docker compose logs nexus` and rerun `./scripts/bootstrap-nexus.sh`; it is idempotent. For registry failures test `docker exec jenkins-ci-cd-lab-jenkins-1 docker login nexus:8082`. For kind failures inspect `kubectl get events -A --sort-by=.lastTimestamp`, pods, and `./scripts/configure-kind-registry.sh`. For pipeline details open each Jenkins build console URL reported by `make demo`.

On macOS Docker Desktop, ensure its Docker daemon is running and allocated sufficient memory (approximately 16 GB host memory is recommended). This lab deliberately does not install host packages or alter the host daemon's insecure-registry configuration.
