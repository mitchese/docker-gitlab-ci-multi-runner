all: build

build:
	@docker build --tag=mitchese/docker-gitlab-ci-multi-runner-docker .

release: build
	@docker build --tag=mitchese/docker-gitlab-ci-multi-runner-docker:$(shell cat VERSION) .
