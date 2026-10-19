#!/bin/sh

if [ $# -ne 2 ]; then
  echo "Usage: $0 [ubuntu|alpine|rhel8|amazonlinux2] VERSION" >&2
  exit 1
fi

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
  --file "dockerfiles/${BASE_IMAGE}-idea.Dockerfile" \
  .

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONTAINER_HOME=/home/my_user
DATA_DIR="$SCRIPT_DIR/system-config-logs-plugins/$BASE_IMAGE"

for f in idea.properties idea.vmoptions; do
  if [ ! -f "$SCRIPT_DIR/$f" ]; then
    echo "Missing $SCRIPT_DIR/$f" >&2
    exit 1
  fi
done
mkdir -p "$DATA_DIR/system" \
         "$DATA_DIR/config" \
         "$DATA_DIR/logs" \
         "$DATA_DIR/plugins"

docker run -it \
  -e DISPLAY=host.docker.internal:0 \
  -e IDEA_PROPERTIES="$CONTAINER_HOME/idea.properties" \
  -e IDEA_VM_OPTIONS="$CONTAINER_HOME/idea.vmoptions" \
  -v "$SCRIPT_DIR/idea.properties:$CONTAINER_HOME/idea.properties" \
  -v "$SCRIPT_DIR/idea.vmoptions:$CONTAINER_HOME/idea.vmoptions" \
  -v "$DATA_DIR/system:$CONTAINER_HOME/system-config-logs-plugins/system" \
  -v "$DATA_DIR/config:$CONTAINER_HOME/system-config-logs-plugins/config" \
  -v "$DATA_DIR/logs:$CONTAINER_HOME/system-config-logs-plugins/logs" \
  -v "$DATA_DIR/plugins:$CONTAINER_HOME/system-config-logs-plugins/plugins" \
  "$TAG"
