#!/bin/bash
set -e
set -x

THIS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

: ${REV:=$(git rev-parse --verify HEAD)}

PDF=$(mktemp)
DIR=$(mktemp -d)
trap "rm -rf ${PDF} ${DIR}" EXIT

# checkout and build pdf for target revision
git clone --recursive git@github.com:noahdesu/paperblah.git ${DIR}
pushd ${DIR}
git checkout ${REV}
./build.sh
mv paper.pdf ${PDF}

# add the pdf and push
git checkout -b builds origin/builds ||
  git checkout --orphan builds && git rm -rf .
mv ${PDF} ${REV}.pdf
rm paper.pdf || true
ln -s ${REV}.pdf paper.pdf
git add paper.pdf ${REV}.pdf
git commit -s -m "publishing paper build"
git push origin builds
