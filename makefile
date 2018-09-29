VERSION := $(shell git describe --tags --dirty --always)
LDFLAGS := -ldflags "-X main.version=$(VERSION)"
-include .env

.PHONY: version


# -
# Local Development
#-


static:
	go get
	CGO_ENABLED=0 GOOS=linux go build -a $(LDFLAGS) -o cj .

fast:
	go build $(LDFLAGS) -o cj

local: fast
	./cj

version:
	git tag $(VERSION)
	git push
	git push origin $(VERSION)


# -
# Docker
#-

build:
	docker build --no-cache -t southclaws/cj:$(VERSION) .

push:
	docker push southclaws/cj:$(VERSION)
	docker tag southclaws/cj:$(VERSION) southclaws/cj:latest
	docker push southclaws/cj:latest
	
run:
	-docker rm cj
	docker run \
		--name cj \
		--network host \
		--env-file .env \
		southclaws/cj:$(VERSION)


# -
# Testing Database
# -

mongodb:
	-docker stop mongodb
	-docker rm mongodb
	docker run --name mongodb -p 27017:27017 -d mongo
