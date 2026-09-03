.PHONY: build test smoke compose-check check
IMAGE ?= red-discordbot:local
build:
	docker build -t $(IMAGE) .
test: build
	IMAGE=$(IMAGE) scripts/smoke-test.sh
	IMAGE=$(IMAGE) scripts/test-container.sh
	IMAGE=$(IMAGE) tests/entrypoint-args.sh
smoke: build
	IMAGE=$(IMAGE) scripts/smoke-test.sh
compose-check:
	docker compose config --quiet
check:
	tests/static.sh
	git diff --check
