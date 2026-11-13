#!/bin/bash
# Publishes the four Labtainer images (built by build_labtainer_images.sh) to the Docker Hub
# repository <REGISTRY>/r2e-cyb-lab (REGISTRY in config/start.config) as
#   lucid-ddos.<container>             the current images, plus lucid-ddos.<container>-<version>
# Labtainer pulls a lab's images only as <REGISTRY>/lucid-ddos.<container>.student; students get
# them from this one repository with lucid-ddos/bin/pull_images.sh, which gives them that name.
# Needs a prior `docker login` of a Docker Hub user with write access to the repository. Every push
# is retried (Docker Hub answers 502/503 now and then); a publish that still fails stops with an
# error, so CI never reports a half-published set as done.
#   usage: publish_images.sh [version tag]
set -eu
VERSION=${1:-}
REGISTRY=$(awk '$1 == "REGISTRY" {print $2; exit}' "$(dirname "$0")/../lucid-ddos/config/start.config")
REPO=$REGISTRY/r2e-cyb-lab
D="docker --context default"
push() {   # push <tag>, up to 4 attempts
  local n
  for n in 1 2 3 4; do
    $D push -q "$1" >/dev/null && return 0
    echo "push of $1 failed (attempt $n), retrying in $((n * 15)) s" >&2
    sleep $((n * 15))
  done
  return 1
}
for c in server attacker1 attacker2 client; do
  img=lucid-ddos.$c.student
  targets="$REPO:lucid-ddos.$c"
  [ -n "$VERSION" ] && targets="$targets $REPO:lucid-ddos.$c-$VERSION"
  for t in $targets; do
    $D tag "$img" "$t"
    push "$t"
    echo "pushed $t"
  done
done
