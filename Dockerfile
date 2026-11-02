# syntax = docker/dockerfile:1.3
# Native-platform build + Go cross-compile (avoids qemu for amd64 on arm64 hosts).
FROM --platform=$BUILDPLATFORM golang:1.26 AS build

ARG TARGETOS
ARG TARGETARCH

WORKDIR /go/src/github.com/mccutchen/go-httpbin

COPY . .

RUN --mount=type=cache,id=gobuild,target=/root/.cache/go-build \
    GOOS=${TARGETOS} GOARCH=${TARGETARCH} CGO_ENABLED=0 make build

FROM gcr.io/distroless/static:nonroot

COPY --from=build /go/src/github.com/mccutchen/go-httpbin/dist/go-httpbin /bin/

EXPOSE 8080
CMD ["/bin/go-httpbin"]
