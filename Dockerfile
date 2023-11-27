FROM quay.io/projectquay/golang:1.21 as builder
ARG OS=linux
ARG ARCH=amd64
ARG NAME=kbot
ARG EXT=""
WORKDIR /go/src/app
COPY . .
RUN make build OS=${OS} ARCH=${ARCH} NAME=${NAME} EXT=${EXT}

FROM scratch as linux
WORKDIR /
COPY --from=builder /go/src/app/bin/* .
COPY --from=alpine:latest /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
ENTRYPOINT [ "./kbot" ]

FROM scratch as darwin
WORKDIR /
COPY --from=builder /go/src/app/bin/* .
COPY --from=alpine:latest /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
ENTRYPOINT [ "./kbot" ]

FROM scratch as arm
WORKDIR /
COPY --from=builder /go/src/app/bin/* .
COPY --from=alpine:latest /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
ENTRYPOINT [ "./kbot" ]

FROM scratch as windows
WORKDIR /
COPY --from=builder /go/src/app/bin/* .
COPY --from=alpine:latest /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
ENTRYPOINT [ "./kbot.exe" ]
