VERSION=v5.2.2
docker manifest create schnell18/tidb-dev:$VERSION
    --amend schnell18/schnell18/tidb-dev:$VERSION-arm64 \
    --amend schnell18/schnell18/tidb-dev:$VERSION-amd64

docker manifest push schnell18/schnell18/tidb-dev:$VERSION
