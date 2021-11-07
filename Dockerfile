# Copyright 2019 PingCAP, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# See the License for the specific language governing permissions and
# limitations under the License.

# Builder image
FROM golang:1.16-alpine as builder

ARG APK_MIRROR="mirrors.tuna.tsinghua.edu.cn"
# switch to local mirror
RUN sed -i "s/dl-cdn.alpinelinux.org/${APK_MIRROR}/g" /etc/apk/repositories

RUN apk add --no-cache \
    wget \
    make \
    git \
    gcc \
    binutils-gold \
    dumb-init \
    musl-dev

RUN mkdir -p /go/src/github.com/pingcap/tidb
WORKDIR /go/src/github.com/pingcap/tidb

# Cache dependencies
COPY go.mod .
COPY go.sum .

RUN GO111MODULE=on go mod download

# Build real binaries
COPY . .
RUN make

# Executable image
FROM alpine:3.14

ARG APK_MIRROR="mirrors.tuna.tsinghua.edu.cn"
# switch to local mirror
RUN sed -i "s/dl-cdn.alpinelinux.org/${APK_MIRROR}/g" /etc/apk/repositories

RUN apk add --no-cache curl mysql-client

COPY --from=builder /go/src/github.com/pingcap/tidb/bin/tidb-server /tidb-server
COPY --from=builder /usr/bin/dumb-init /usr/local/bin/dumb-init

WORKDIR /

EXPOSE 4000

ENTRYPOINT ["/usr/local/bin/dumb-init", "/tidb-server"]
