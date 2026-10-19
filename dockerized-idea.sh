#!/bin/sh

if [ $# -ne 2 ]; then
  echo "Usage: $0 [ubuntu|alpine] VERSION" >&2
  exit 1
fi

#https://download.jetbrains.com/idea/idea-2026.2.3-aarch64.tar.gz

set -xeuo pipefail

BASE_IMAGE=$1
VERSION=$2

build_filename() {
  builtin local ARCH=$(uname -m)
  builtin local ARCH_SUFFIX=$([ "$ARCH" = "arm64" ] || [ "$ARCH" = "aarch64" ] && echo "-aarch64")
  echo "idea-${VERSION}${ARCH_SUFFIX}.tar.gz"
}

FILENAME="$(build_filename)"

echo "Running $VERSION from $([ -f "./builds/$FILENAME" ] && echo "./builds/$FILENAME" || echo "URL")"

TAG="intellij-idea-$BASE_IMAGE:$VERSION"

set -x
docker build \
  --build-arg INSTALLER_FILENAME=$FILENAME \
  --tag "$TAG" \
  --file "${BASE_IMAGE}-idea.Dockerfile" \
  .

docker run -it -e DISPLAY=host.docker.internal:0 "$TAG"
