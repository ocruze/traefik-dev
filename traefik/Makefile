.DEFAULT_GOAL := help

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: up
up: ## Launch docker containers
	docker compose up -d --build --remove-orphans

.PHONY: down
down: ## Take down docker containers
	docker compose down --remove-orphans

.PHONY: bash
bash: ## Enter with bash into the traefik docker container
	docker exec -it traefik sh