Container Fixture Builder
=========================

This directory contains all the data and a script to build a docker fixture and push it to
dockerhub.

**This directory is NOT a part of the other fixtures on fedorapeople.**
**The script is NOT included when running `make fixtures`.**

build_and_push.sh
-----------------

This is a tool to build minimal containers that are related to each other in predictable ways. It
creates:

  * Manifests that share blobs
  * Manifests that do not share blobs
  * Manifest Lists that share manifests
  * Manifest Lists that do not share manifests

To generate manifest lists, experimental Docker CLI commands are required.
https://docs.docker.com/engine/reference/commandline/manifest_create/

.. code-block:: bash

   # Format
   ./build_and_push.sh <upstream_org> <upstream_repo>

   # Example
   ./build_and_push.sh pulp test-fixture-1
