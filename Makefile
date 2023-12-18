APP:=$(shell basename -s .git $(shell git remote get-url origin))
VERSION=$(shell git describe --tags --abbrev=0)-$(shell git rev-parse --short HEAD)
OS:=linux
ARCH:=amd64
#NAME:=kbot
EXT:=""
REGISTRY:=lawrider

format:
	gofmt -s -w ./

lint:
	golangci-lint

test:
	go test -v

get:
	go get

build: format get
	CGO_ENABLED=0 GOOS=${OS} GOARCH=${ARCH} go build -v -o bin/${APP}${EXT} -ldflags "-X="github.com/LawRider/kbot/cmd.appVersion=${VERSION}

#linux: format
#	TARGETARCH="amd64"
#	CGO_ENABLED=0 GOOS=linux GOARCH=${TARGETARCH} go build -v -o bin/kbot -ldflags "-X="github.com/LawRider/kbot/cmd.appVersion=${VERSION}

#macos: format
#	TARGETARCH="amd64"
#	CGO_ENABLED=0 GOOS=darwin GOARCH=${TARGETARCH} go build -v -o bin/kbot -ldflags "-X="github.com/LawRider/kbot/cmd.appVersion=${VERSION}

#arm: format
#	TARGETARCH="arm64"
#	CGO_ENABLED=0 GOOS=linux GOARCH=${TARGETARCH} go build -v -o bin/kbot -ldflags "-X="github.com/LawRider/kbot/cmd.appVersion=${VERSION}

#windows: format
#	TARGETARCH="amd64"
#	CGO_ENABLED=0 GOOS=windows GOARCH=${TARGETARCH} go build -v -o bin/kbot.exe -ldflags "-X="github.com/LawRider/kbot/cmd.appVersion=${VERSION}

image:
	docker build --target=${OS} --build-arg OS=${OS} --build-arg ARCH=${ARCH} --build-arg EXT=${EXT} --build-arg VERSION=${VERSION} -t ${REGISTRY}/${APP}:${VERSION}-${ARCH} .

push:
	docker push ${REGISTRY}/${APP}:${VERSION}-${ARCH}

clean:
	rm -rf bin/
	docker rmi ${REGISTRY}/${APP}:${VERSION}-${ARCH}
