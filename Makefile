APP = $(shell basename -s .git $(shell git remote get-url origin))
VERSION = $(shell git describe --tags --abbrev=0)-$(shell git rev-parse --short HEAD)
ARGS1 := $(word 1,$(MAKECMDGOALS)) 
ARGS2 := $(word 2,$(MAKECMDGOALS))
OS ?= $(if $(filter apple,$(ARGS1)),darwin,$(if $(filter windows,$(ARGS1)),windows,linux))
ARCH ?= $(if $(filter arm arm64,$(ARGS2)),arm64,$(if $(filter amd amd64,$(ARGS2)),amd64,amd64))
BUILD_DIR = bin
DOCKER_HUB_USER = lawrider
REGISTRY = ghcr.io
GITHUB_USER = lawrider

format:
	gofmt -s -w ./

lint:
	golangci-lint

test:
	go test -v

get:
	go get

build: format get
	CGO_ENABLED=0 GOOS=${OS} GOARCH=${ARCH} go build -v -o ${BUILD_DIR}/${APP}${EXT} -ldflags "-X="github.com/LawRider/kbot/cmd.appVersion=${VERSION}

linux: build # linux (arm|arm64|amd|amd64)

apple: build

windows: EXT = .exe
windows: build

image:
	#docker build --target=${OS} --build-arg OS=${OS} --build-arg ARCH=${ARCH} --build-arg EXT=${EXT} --build-arg VERSION=${VERSION} -t ${DOCKER_HUB_USER}/${APP}:${VERSION}-${OS}-${ARCH} .
	docker build --target=${OS} --build-arg OS=${OS} --build-arg ARCH=${ARCH} --build-arg EXT=${EXT} --build-arg VERSION=${VERSION} -t ${REGISTRY}/${GITHUB_USER}/${APP}:${VERSION}-${OS}-${ARCH} .

image-linux: image

image-apple: OS = darwin
image-apple = image

image-windows: OS = windows
image-windows = image

push:
	#docker push ${DOCKER_HUB_USER}/${APP}:${VERSION}-${OS}-${ARCH}
	docker push ${REGISTRY}/${GITHUB_USER}/${APP}:${VERSION}-${OS}-${ARCH}

clean:
	rm -rf ${BUILD_DIR}/

clean-image:
	#docker rmi ${DOCKER_HUB_USER}/${APP}:${VERSION}-${OS}-${ARCH}
	docker rmi ${REGISTRY}/${GITHUB_USER}/${APP}:${VERSION}-${OS}-${ARCH}

clean-all:
	clean clean-image
