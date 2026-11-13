#!/bin/bash
# Downloads the four container images of the lab from the Docker Hub repository
# <REGISTRY>/r2e-cyb-lab (tags lucid-ddos.<container>) and names them as Labtainer expects them,
# <REGISTRY>/lucid-ddos.<container>.student:latest (REGISTRY in config/start.config). Labtainer
# uses such a local image and does not pull it. Run it once before the first start of the lab and
# again after every update of the lab (then start with `labtainer -r lucid-ddos`).
#   usage: pull_images.sh
set -eu
REGISTRY=$(awk '$1 == "REGISTRY" {print $2; exit}' "$(dirname "$0")/../config/start.config")
REPO=$REGISTRY/r2e-cyb-lab
for c in server attacker1 attacker2 client; do
  echo "== $c"
  docker pull "$REPO:lucid-ddos.$c"
  docker tag "$REPO:lucid-ddos.$c" "$REGISTRY/lucid-ddos.$c.student:latest"
  docker rmi "$REPO:lucid-ddos.$c" >/dev/null     # removes only the second name, not the image
done
echo "The images of lucid-ddos are ready; start the lab with: labtainer lucid-ddos"
