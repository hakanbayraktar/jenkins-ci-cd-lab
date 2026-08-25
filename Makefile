.DEFAULT_GOAL := help
.PHONY: help doctor up demo verify status logs down reset

help:
	@awk 'BEGIN {FS=":.*##"}; /^[a-zA-Z_-]+:.*##/ {printf "%-12s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

doctor: ## Check host prerequisites and lab ports
	@./scripts/doctor.sh

up: ## Create or reuse the fully configured lab
	@./scripts/setup.sh

demo: ## Run a real CI build and wait for automatic CD
	@./scripts/trigger-demo.sh

verify: ## Run automated end-to-end validation
	@./scripts/verify.sh

status: ## Show services, cluster and application state
	@./scripts/status.sh

logs: ## Follow Jenkins, DIND and Nexus logs
	@docker compose logs -f jenkins jenkins-docker nexus

down: ## Stop lab services while retaining data volumes
	@./scripts/teardown.sh

reset: ## Remove only resources owned by this lab
	@./scripts/reset.sh
