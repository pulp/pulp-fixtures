Pulp Fixtures
=============

Pulp Fixtures is a collection of raw fixture data, scripts for compiling that
data into a useful format, and make targets for controlling the whole mess.

Why does Pulp Fixtures exist? It exists so that the fixture data used by [Pulp
Smash](http://pulp-smash.readthedocs.io) can easily be recreated, and can be
altered in a controlled way. Pulp Smash does not directly make use of Pulp
Fixtures. Instead:

1. A user clones the Pulp Fixtures repository. The "user" could be a human, or
   a bot like Jenkins.
2. The user compiles the fixture data they want.
3. The user uploads that fixture data to an HTTP server.
4. The user ensures that their Pulp Smash installation is configured to use the
   uploaded fixture data. See
   [`pulp_smash.constants`](http://pulp-smash.readthedocs.io/en/latest/api/pulp_smash.constants.html).

For exact usage instructions, clone this repository and run `make help`.
