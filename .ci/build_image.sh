#!/bin/sh

set -euv

# Lint
make lint

# Build
docker build -f Containerfile -t pulp/pulp-fixtures .

# Test
docker run --rm -d -e BASE_URL=http://localhost:8000 -p 8000:80 --name pulp-fixtures pulp/pulp-fixtures
sleep 2 # it can take a couple seconds for sed to run and nginx to boot
curl --fail localhost:8000/file/PULP_MANIFEST
curl --fail localhost:8000/debian/dists/ragnarok/Release
curl -L localhost:8000/rpm-unsigned/?badtoken | grep "Wrong auth token"
curl --fail -L localhost:8000/rpm-unsigned/?secret
curl --fail -L localhost:8000/file-large/?parameter
test "$(curl localhost:8000/rpm-mirrorlist-good)" = "http://localhost:8000/rpm-unsigned/"
pip install --trusted-host localhost -i http://localhost:8000/python-pypi/simple/ shelf-reader
curl --fail -o /dev/null localhost:8000/docker/busybox:latest.tar
curl --fail -o /dev/null localhost:8000/puppet/pulpqe-dummypuppet.tar.gz
curl --fail localhost:8000/ostree/small/summary
curl localhost:8000/rpm-zchunk/repodata/ | grep filelists.xml.zck
docker stop pulp-fixtures
