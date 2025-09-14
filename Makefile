MAKEFLAGS += --silent

OPTIONS ?= --build --quiet-pull --force-recreate --no-color --remove-orphans
APP ?= api

.PHONY: all init test ci clean
all:
	terraform init -upgrade
	terraform fmt -recursive
	terraform validate
	TF_LOG=debug terraform plan

## Initialize terraform remote state
init:
	[ -d .terraform ] || terraform $@

## Pass arguments through to terraform which require remote state
apply console destroy graph plan output providers show validate: init
	terraform $@

## Pass arguments through to terraform which do not require remote state
get fmt version:
	terraform $@

compose:
	docker compose up $(OPTIONS) -d

ci:
	COMPOSE_FILE=compose.yml:compose.ci.yml DOCKER_BUILDKIT=1 \
							 docker compose up $(OPTIONS) --exit-code-from ci

healthcheck:
	docker inspect $(APP) --format "{{ (index (.State.Health.Log) 0).Output }}"

test:
	[ -f ./test/test.sh ] && ./test/test.sh || true

clean:
	docker-compose down --remove-orphans -v --rmi local
	rm -rf .terraform *.tfstate

-include include.mk
