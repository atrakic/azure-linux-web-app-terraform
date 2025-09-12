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

.PHONY: test
test:
	[ -f ./test/test.sh ] && ./test/test.sh || true

ci:
	COMPOSE_FILE=compose.yml:compose.ci.yml \
	DOCKER_BUILDKIT=1 docker-compose up --build --force-recreate ci -d

clean:
	docker-compose down --remove-orphans -v --rmi local
	rm -rf .terraform *.tfstate

-include include.mk
