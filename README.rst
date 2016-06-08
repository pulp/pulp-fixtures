Pulp Fixtures
=============

Pulp Fixtures is a collection of raw fixture data, scripts for compiling that
data into a useful format, and make targets for controlling the whole mess.

Why does Pulp Fixtures exist? It exists so that the fixture data used by `Pulp
Smash`_  can easily be recreated, and can be altered in a controlled way. Pulp
Smash does not directly make use of Pulp Fixtures. Instead:

1. A user clones the Pulp Fixtures repository. The "user" could be a human, or
   a bot like Jenkins.
2. The user compiles the fixture data they want.
3. The user uploads that fixture data to an HTTP server.
4. The user ensures that their Pulp Smash installation is configured to use the
   uploaded fixture data. See `pulp_smash.constants`_.

For exact usage instructions, clone this repository and run ``make help``.

Dependencies
------------

The fixture generation scripts do little more than call out to system utilities
and mangle the results. It's the user's responsibility to ensure the necessary
utilities are available and usable. Dependencies are listed below, according to
make target. Common system utilities like ``fmt``, ``patch`` and ``realpath``
are omitted.

``fixtures/docker``
    The ``docker`` utility must be available.

    Ensure the service is running and usable by the current user. This may
    require adding the current user to an appropriate group and reloading
    permissions, with a command such as ``gpasswd --add $(id -u) docker &&
    newgrp``.

``fixtures/rpm``
    The ``createrepo`` and ``modifyrepo`` utilities must be available.

``fixtures/rpm-invalid-updateinfo``
    See ``fixtures/rpm``.

``fixtures/rpm-updated-updateinfo``
    See ``fixtures/rpm``.

.. _Pulp Smash: http://pulp-smash.readthedocs.io
.. _pulp_smash.constants:
    http://pulp-smash.readthedocs.io/en/latest/api/pulp_smash.constants.html
