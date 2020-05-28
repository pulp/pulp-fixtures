#!/bin/bash
#!/usr/bin/env bash

# docker-push.sh: Push (Upload) image to docker.
# Image must be already tagged.

# TODO: These are already hardcoded in .travis.yml for the build task
#
# Pulp is an organization (not an individual user account) on Docker:
# https://docker.io/organization/pulp
# For test publishes, one can override this to any org or user.
DOCKER_PROJECT_NAME=${DOCKER_USER_OR_ORG_NAME:-pulp}
# The image name, AKA the Docker repo
DOCKER_REPO_NAME=${DOCKER_USER_OR_ORG_NAME:-pulp-fixtures}
# The image tag
IMAGE_TAG=${DOCKER_USER_OR_ORG_NAME:-latest}

echo "$DOCKER_BOT_PASSWORD" | docker login -u "$DOCKER_BOT_USERNAME" --password-stdin docker.io
docker tag pulp/pulp-fixtures "docker.io/$DOCKER_PROJECT_NAME/$DOCKER_REPO_NAME:$IMAGE_TAG"
docker push "docker.io/$DOCKER_PROJECT_NAME/$DOCKER_REPO_NAME:$IMAGE_TAG"
