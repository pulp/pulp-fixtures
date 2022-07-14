.. image:: https://github.com/pulp/pulp-fixtures/workflows/Build%20and%20publish%20pulp-fixture%20OCI%20Image/badge.svg


Pulp Fixtures
=============

Pulp Fixtures is a collection of raw fixture data, scripts for compiling that
data into a useful format, and make targets for controlling the whole mess.

Note that the latest version of these fixtures are available as `hosted fixtures`_.

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

Container
---------

You can run these fixtures locally using a container. We host the container images at both quay and
docker hub::

    podman run -d --rm -p 8000:8080 docker.io/pulp/pulp-fixtures:latest
    podman run -d --rm -p 8000:8080 quay.io/pulp/pulp-fixtures:latest

Or with docker::

    docker run -d --rm -p 8000:8080 docker.io/pulp/pulp-fixtures:latest
    docker run -d --rm -p 8000:8080 quay.io/pulp/pulp-fixtures:latest

You can also build and run the pulp fixtures container locally with podman/buildah::

    buildah bud -f Containerfile -t pulp/pulp-fixtures .
    podman run -d -p 8000:8080 pulp/pulp-fixtures

Or you can use docker::

    docker build -f Containerfile -t pulp/pulp-fixtures .
    docker run -d -p 8000:8080 pulp/pulp-fixtures

By default the base url is ``http://localhost:8000``. If you want to change this, run::

    podman run -d -e BASE_URL=http://pulp-fixtures:8080 pulp/pulp-fixtures

Dependencies
------------

Most make targets are implemented as bash scripts. Bash 4.4 or newer is
required. In addition, exotic dependencies are listed below, according to make
target. Common dependencies like ``fmt``, ``patch`` and ``realpath`` are
omitted.

Some RPM, SRPM and DRPM fixtures are signed with an OpenPGP-compatible keypair.
See ``make help``.

.. WARNING:: The private key used to sign RPM, SRPM and DRPM files is publicly
    available. The signatures on these files afford absolutely *no* security.
    The signatures are present only for testing purposes.

``help``
    No exotic dependencies are needed.

``lint``
    See ``lint-pylint`` and ``lint-shellcheck``.

``lint-pylint``
    The ``pylint`` executable must be available.

``lint-shellcheck``
    The ``shellcheck`` executable must be available.

``clean``
    No exotic dependencies are needed.

``fixtures/debian``
    The ``gnupg``, ``equivs``, and ``reprepro`` packages must be installed.

``fixtures/debian-invalid``
    Depends on the ``fixtures/debian`` target.

``fixtures/docker``
    The ``docker`` executable must be available.

    Ensure the service is running and usable by the current user. This may
    require adding the current user to an appropriate group and reloading
    permissions, with a command such as ``gpasswd --add $(id -u) docker &&
    newgrp``.

``fixtures/drpm-signed``
    The ``createrepo``, ``makedeltarpm`` and ``rpmsign`` utilities must be available.

``fixtures/drpm-unsigned``
    The ``createrepo`` and ``makedeltarpm`` executables must be available.

``fixtures/file``
    No exotic dependencies are needed.

``fixtures/file2``
    No exotic dependencies are needed.

``fixtures/file-invalid``
    No exotic dependencies are needed.

``fixtures/file-large``
    No exotic dependencies are needed.

``fixtures/file-many``
    No exotic dependencies are needed.

``fixtures/file-perf``
    No exotic dependencies are needed.

``fixtures/file-dl-forward``
    No exotic dependencies are needed.

``fixtures/file-dl-reverse``
    No exotic dependencies are needed.

``fixtures/file-mixed``
    See ``fixtures/file``.

``fixtures/puppet``
    The ``puppet`` executable must be available.

``fixtures/ostree``
    The ``ostree`` executable must be available.

``fixtures/python-pypi``
    The ``jq``, ``jinja2`` and ``python3`` executables must be available.

``fixtures/rpm-alt-layout``
    See ``fixtures/rpm-unsigned``.

``fixtures/rpm-incomplete-filelists``
    See ``fixtures/rpm-unsigned``.

``fixtures/rpm-incomplete-other``
    See ``fixtures/rpm-unsigned``.

``fixtures/rpm-invalid-rpm``
    No exotic dependencies are needed.

``fixtures/rpm-invalid-updateinfo``
    See ``fixtures/rpm-unsigned``.

``fixtures/rpm-string-version-updateinfo``
    See ``fixtures/rpm-unsigned``.

``fixtures/rpm-long-updateinfo``
    See ``fixtures/rpm-unsigned``.

``fixtures/rpm-mirrorlist-bad``
    No exotic dependencies are needed.

    .. NOTE:: There is no known specification (syntax, naming, etc) of
        mirrorlist files. These files are modeled on CentOS mirrorlists. See:
        http://mirrorlist.centos.org/?release=6&arch=x86_64&repo=os. For an
        example of an alternate implementation, see:
        https://www.archlinux.org/mirrorlist/. As a result, this target may
        exhibit erroneous behaviour.

``fixtures/rpm-mirrorlist-good``
    See ``fixtures/rpm-mirrorlist-bad``.

``fixtures/rpm-mirrorlist-mixed``
    See ``fixtures/rpm-mirrorlist-bad``.

``fixtures/rpm-missing-filelists``
    See ``fixtures/rpm-unsigned``.

``fixtures/rpm-missing-other``
    See ``fixtures/rpm-unsigned``.

``fixtures/rpm-missing-primary``
    See ``fixtures/rpm-unsigned``.

``fixtures/rpm-modular``
    The ``createrepo`` and ``modifyrepo`` executables must be available.

    .. NOTE:: All packages and metadata (modules, defaults, obsoletes and advisories)
        are taken and combined from dnf-ci-fedora-modular, dnf-ci-thirdparty-modular,
        dnf-ci-fedora-modular-updates and dnf-ci-obsoletes repositories found
        `here<https://github.com/rpm-software-management/ci-dnf-stack>`_.
        ``updateinfo.xml`` was updated with modules and packages names and version to
        not need more binary data.

``fixtures/rpm-pkglists-updateinfo``
    See ``fixtures/rpm-unsigned``.

``fixtures/rpm-references-updateinfo``
    See ``fixtures/rpm-unsigned``.

``fixtures/rpm-richnweak-deps``
    The ``createrepo`` executable must be available.

``fixtures/rpm-signed``
    The ``createrepo``, ``modifyrepo`` and ``rpmsign`` executables must be
    available.

``fixtures/rpm-unsigned``
    The ``createrepo`` and ``modifyrepo`` executables must be available.

``fixtures/rpm-updated-updateinfo``
    See ``fixtures/rpm-unsigned``.

``fixtures/rpm-with-modules``
    The ``createrepo`` and ``modifyrepo`` executables must be available.

``fixtures/rpm-with-non-ascii``
    The ``fedpkg`` executable must be available.

``fixtures/rpm-with-non-utf-8``
    The ``fedpkg`` executable must be available.

``fixtures/rpm-with-sha512``
    See ``fixtures/rpm-unsigned``.

``fixtures/rpm-with-vendor``
    The ``fedpkg`` and ``createrepo`` executables must be available.

``fixtures/rpm-with-pulp-distribution``
    See ``fixtures/rpm-unsigned``.

``fixtures/srpm-duplicate``
    See ``fixtures/srpm-richnweak-deps``.

``fixtures/srpm-richnweak-deps``
    The ``rpmdev-setuptree``, ``rpmbuild`` and ``createrepo`` executable must be
    available.

``fixtures/srpm-signed``
    The ``createrepo`` and ``modifyrepo`` executables must be available.

``fixtures/srpm-unsigned``
    The ``createrepo``, ``modifyrepo`` and ``rpmsign`` executables must be
    available.

``gnupghome``
    The ``gpg`` executable must be available.

Package Signatures
------------------

The RPM, SRPM and DRPM assets are unsigned, and signatures are added as needed
when generating fixtures. The opposite approach of using signed assets and
stripping signatures as needed is less safe, as the keypair can more easily go
out of sync with the assets. In addition, the ``makedeltarpm`` utility generates
unsigned DRPMs, meaning the ``fixtures/drpm`` target must perform package
signing.

By default, GnuPG works with files in the ``~/.gnupg`` directory, and the
``rpmsign`` executable works with the ``~/.rpmmacros`` file. (Other RPM
packaging tools also use this file.) It is unacceptable for Pulp Fixtures to
modify these files. Given this, how can package signing be done?

Altering the behaviour of GnuPG is easy: if the ``GNUPGHOME`` environment
variable is set, the named directory is used instead of ``~/.gnupg``.

Altering the behaviour of ``rpmsign`` is harder: It includes hard-coded
references to ``~/.rpmmacros``. The solution adopted is to pass all needed
macros via the ``--define`` option, so that the ``~/.rpmmacros`` file need not
be consulted. Using this option is hacky, as it is not listed in the ``rpmsign``
man page, and it is mentioned only briefly in the ``rpm`` man page. However,
this solution is more targeted than an alternative solution like temporarily
overriding the ``HOME`` environment variable.

To see which packages have been signed with the Pulp QE key, execute a command
like the following:

.. code-block:: sh

    find fixtures \( -name '*.rpm' -o -name '*.srpm' -o -name '*.drpm' \) | xargs rpm --checksig

If a line like the following is shown, then the named package is unsigned::

    fixtures/rpm-unsigned/lion-0.4-1.noarch.rpm: sha1 md5 OK

If a line like the following is shown, then the named package is signed::

    fixtures/rpm/lion-0.4-1.noarch.rpm: (RSA) sha1 ((MD5) PGP) md5 NOT OK (MISSING KEYS: RSA#269d9d98 (MD5) PGP#269d9d98)

The ``MISSING KEYS`` message is present because the Pulp QE public key has not
been imported to your keystore. You should not import it, as **the Pulp QE
private key is public.** It exists for testing purposes, and provides no
assurances of identity.

.. _hosted fixtures: https://fixtures.pulpproject.org/
.. _Pulp #2020: https://pulp.plan.io/issues/2020
.. _Pulp RPM Errata:
    https://docs.pulpproject.org/plugins/pulp_rpm/tech-reference/yum-plugins.html#errata
.. _Pulp Smash: http://pulp-smash.readthedocs.io
.. _pulp_smash.constants:
    https://pulp-smash.readthedocs.io/en/latest/api/pulp_smash.constants.html
