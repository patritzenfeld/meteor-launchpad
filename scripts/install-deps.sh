#!/bin/bash

set -e

printf "\n[-] Installing base OS dependencies...\n\n"

# install base dependencies

apt-get update

# ensure we can get an https apt source if redirected
# https://github.com/jshimko/meteor-launchpad/issues/50

apt-get install -y --no-install-recommends apt-transport-https ca-certificates curl bzip2 libarchive-tools build-essential git gpg gnupg2 gosu

### Conda
MINICONDA_URL="https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh"
MINICONDA_INSTALLER="$(mktemp -t miniconda_XXX.sh)"
curl -fsSL --connect-timeout 10 --max-time 120 "${MINICONDA_URL}" -o "${MINICONDA_INSTALLER}"
bash "${MINICONDA_INSTALLER}" -b -p "/opt/conda"
