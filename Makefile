# The base URL of where fixtures are hosted. The default is compatible with
# `python3 -m http.server`.
base_url=http://localhost:8000

help:
	@echo "Please use \`make <target>' where <target> is one of:"
	@echo "    help"
	@echo "        Show this message."
	@echo "    lint"
	@echo "        Run all of the linters."
	@echo "    lint-pylint"
	@echo "        Run pylint on all Python scripts."
	@echo "    lint-shellcheck"
	@echo "        Run shellcheck on all shell scripts."
	@echo "    clean"
	@echo "        Remove fixture data and 'gnupghome'."
	@echo "    fixtures"
	@echo "        Create all fixture data."
	@echo "    fixtures/docker"
	@echo "        Create Docker fixture data."
	@echo "    fixtures/drpm-signed"
	@echo "        Create DRPM fixtures with signed packages."
	@echo "    fixtures/drpm-unsigned"
	@echo "        Create DRPM fixtures with unsigned packages."
	@echo "    fixtures/file"
	@echo "        Create file fixtures."
	@echo "    fixtures/file2"
	@echo "        Create file fixtures, with same file names but different"
	@echo "        contents."
	@echo "    fixtures/file-invalid"
	@echo "        Create file fixtures with a file that doesn't match"
	@echo "        the manifest"
	@echo "    fixtures/file-large"
	@echo "        Create large file fixtures, with 10 file fixtures."
	@echo "    fixtures/file-many"
	@echo "        Create many file fixtures, with 250 file fixtures."
	@echo "    fixtures/file-perf"
	@echo "        Create smal file fixtures, with 100000 file fixtures for"
	@echo "        the performance tests."
	@echo "    fixtures/file-mixed"
	@echo "        Create File fixtures with some not available files on the"
	@echo "        PULP_MANIFEST."
	@echo "    fixtures/ostree"
	@echo "        Create a OSTree ostree repositories."
	@echo "    fixtures/puppet"
	@echo "        Create a dummy Puppet module."
	@echo "    fixtures/python-pypi [base_url=...]"
	@echo "        Create a PyPI Python repository."
	@echo "    fixtures/rpm-alt-layout"
	@echo "        Create an RPM repository with packages in a dedicated"
	@echo "        directory."
	@echo "    fixtures/rpm-with-modules"
	@echo "        Create an RPM repository with modules"
	@echo "    fixtures/rpm-incomplete-filelists"
	@echo "        Create an RPM repository with an incomplete filelists.xml."
	@echo "    fixtures/rpm-incomplete-other"
	@echo "        Create an RPM repository with an incomplete other.xml."
	@echo "    fixtures/rpm-invalid-rpm"
	@echo "        Create an invalid RPM."
	@echo "    fixtures/rpm-invalid-updateinfo"
	@echo "        Create RPM fixtures with invalid updateinfo.xml."
	@echo "    fixtures/rpm-string-version-updateinfo"
	@echo "        Create RPM fixtures with string version in updateinfo.xml see #1741011."
	@echo "    fixtures/long-updateinfo"
	@echo "        Create an RPM repo with an enormous updateinfo.xml."
	@echo "    fixtures/rpm-mirrorlist-bad [base_url=...]"
	@echo "    fixtures/rpm-mirrorlist-good [base_url=...]"
	@echo "    fixtures/rpm-mirrorlist-mixed [base_url=...]"
	@echo "        Create a text file referencing one or more RPM repositories."
	@echo "        'bad' and 'good' reference unusable and usable repositories,"
	@echo "        respectively, and 'mixed' references both."
	@echo "    fixtures/rpm-missing-filelists"
	@echo "        Create an RPM repository without filelists.xml."
	@echo "    fixtures/rpm-missing-other"
	@echo "        Create an RPM repository without other.xml."
	@echo "    fixtures/rpm-missing-primary"
	@echo "        Create an RPM repository without primary.xml."
	@echo "    fixtures/rpm-pkglists-updateinfo"
	@echo "        Create RPM fixtures with multiple pkglists and collections"
	@echo "        in updateinfo.xml."
	@echo "    fixtures/rpm-references-updateinfo"
	@echo "        Create RPM fixtures with updateinfo.xml containing references."
	@echo "    fixtures/rpm-richnweak-deps"
	@echo "        Create RPM fixture data with packages with regular,"
	@echo "        weak and very weak dependencies."
	@echo "    fixtures/rpm-signed"
	@echo "        Create RPM fixture data with signed packages."
	@echo "    fixtures/rpm-unsigned"
	@echo "        Create RPM fixture data with unsigned packages."
	@echo "    fixtures/rpm-updated-updateinfo"
	@echo "        Create RPM fixtures with updated updateinfo.xml."
	@echo "    fixtures/rpm-with-non-ascii"
	@echo "        Create an RPM file with non-ascii characters."
	@echo "    fixtures/rpm-with-non-utf-8"
	@echo "        Create an RPM file with non-utf-8 characters."
	@echo "    fixtures/rpm-with-sha-512"
	@echo "        Create RPM fixture data with checksum as 'sha512'."
	@echo "    fixtures/rpm-with-sha-1-modular"
	@echo "        Create RPM Modules fixture data with checksum as 'sha1'."
	@echo "    fixtures/rpm-with-pulp-distribution"
	@echo "        Create an RPM repository with extra files and a"
	@echo "        PULP_DISTRIBUTION.xml file."
	@echo "    fixtures/rpm-with-vendor"
	@echo "        Create an RPM repository with an RPM that has a vendor."
	@echo "    fixtures/srpm-duplicate"
	@echo "        Create SRPM fixture data with duplicate entries in repodata."
	@echo "    fixtures/srpm-richnweak-deps"
	@echo "        Create SRPM fixture data with packages with regular,"
	@echo "        weak and very weak dependencies."
	@echo "    fixtures/srpm-signed"
	@echo "        Create SRPM fixture data with signed packages."
	@echo "    fixtures/srpm-unsigned"
	@echo "        Create SRPM fixture data with unsigned packages."
	@echo "    gnupghome"
	@echo "        Create a GnuPG home directory and import the Pulp QE public"
	@echo "        key."
	@echo ""
	@echo "base_url should be set to where the fixtures will be hosted. It"
	@echo "defaults to $(base_url), for compatibility with 'python3 -m"
	@echo "http.server'. It should not have a trailing slash."

clean:
	rm -rf fixtures/* gnupghome

# xargs communicates return values better than find's `-exec` argument.
lint: lint-pylint lint-shellcheck

# Refactoring out common code is very easy to do. it's also pretty easy to deal
# with Python's import machinery with Python 3.5+: one can use
# importlib.util.spec_from_file_location and importlib.util.module_from_spec to
# load a file and insert it anywhere into the Python interpreter's namespace.
# The real problem is that we don't have a namespace reserved for Pulp Fixtures,
# so any namespace we choose might might cause forward compatibility issues.
lint-pylint:
	find . -name '*.py' -print0 | xargs -0 pylint --disable duplicate-code

lint-shellcheck:
	find . -name '*.sh' -print0 | xargs -0 shellcheck

all: fixtures
	$(warning The `all` target is deprecated. Use `fixtures` instead.)

fixtures: fixtures/docker \
	fixtures/drpm-signed \
	fixtures/drpm-unsigned \
	fixtures/file \
	fixtures/file-chunked \
	fixtures/file2 \
	fixtures/file-invalid \
	fixtures/file-large \
	fixtures/file-many \
	fixtures/file-perf \
	fixtures/file-mixed \
	fixtures/python-pypi \
	fixtures/rpm-alt-layout \
	fixtures/rpm-with-modules \
	fixtures/rpm-incomplete-filelists \
	fixtures/rpm-incomplete-other \
	fixtures/rpm-invalid-rpm \
	fixtures/rpm-invalid-updateinfo \
	fixtures/rpm-string-version-updateinfo \
	fixtures/rpm-long-updateinfo \
	fixtures/rpm-mirrorlist-bad \
	fixtures/rpm-mirrorlist-good \
	fixtures/rpm-mirrorlist-mixed \
	fixtures/rpm-missing-filelists \
	fixtures/rpm-missing-other \
	fixtures/rpm-missing-primary \
	fixtures/rpm-pkglists-updateinfo \
	fixtures/rpm-references-updateinfo \
	fixtures/rpm-richnweak-deps \
	fixtures/rpm-signed \
	fixtures/rpm-unsigned \
	fixtures/rpm-packages-updateinfo \
	fixtures/rpm-updated-updateinfo \
	fixtures/rpm-with-non-ascii \
	fixtures/rpm-with-sha-512 \
	fixtures/rpm-with-sha-1-modular \
	fixtures/rpm-with-vendor \
	fixtures/rpm-with-pulp-distribution \
	fixtures/srpm-duplicate \
	fixtures/srpm-richnweak-deps \
	fixtures/srpm-signed \
	fixtures/srpm-unsigned


fixtures/docker:
	docker/gen-fixtures.sh $@

fixtures/drpm-signed: gnupghome
	GNUPGHOME=$$(realpath -e gnupghome) rpm/gen-fixtures-delta.sh \
		--signing-key ./rpm/GPG-RPM-PRIVATE-KEY-pulp-qe $@ rpm/assets-drpm

fixtures/drpm-unsigned:
	rpm/gen-fixtures-delta.sh $@ rpm/assets-drpm

fixtures/file:
	file/gen-fixtures.sh $@

fixtures/file-chunked:
	file/gen-chunked-fixtures.sh $@

fixtures/file2:
	file/gen-fixtures.sh $@

fixtures/file-invalid:
	file/gen-fixtures.sh $@
	echo 'blah' > $@/4.iso
	echo 4.iso,4a36e4eede4a61fd547040b53b1656b6dd489bd5bc4c0dd5fe55892dcf1669e8,1048576 >> $@/PULP_MANIFEST

fixtures/file-large:
	file/gen-fixtures.sh $@ --number 10 --file-size 10M

fixtures/file-many:
	file/gen-fixtures.sh $@ --number 250

fixtures/file-perf:
	file/gen-fixtures.sh $@ --number 100000 --file-size 50

fixtures/file-mixed:
	file/gen-fixtures.sh $@
	echo missing-1.iso,4a36e4eede4a61fd547040b53b1656b6dd489bd5bc4c0dd5fe55892dcf1669e8,1048576 >> $@/PULP_MANIFEST
	echo missing-2.iso,ab6d91d4956d1a009bd6d03b3591f95aaae83b36907f77dd1ac71c400715b901,2097152 >> $@/PULP_MANIFEST

fixtures/ostree:
	ostree/gen-fixtures.sh $@/small

# Commented out AND removved from the generation: See SATQE-3469
# fixtures/puppet:
# 	puppet/gen-module.sh $@

fixtures/python-pypi:
	python/gen-pypi-repo.sh $@ python/pypi-assets $(base_url)

fixtures/rpm-alt-layout:
	rpm/gen-fixtures.sh --packages-dir packages/keep-going $@ rpm/assets

fixtures/rpm-incomplete-filelists:
	rpm/gen-fixtures.sh $@ rpm/assets
	gunzip $@/repodata/*-filelists.xml.gz
	sed -i -e '/<package /,/<\/package>/d' $@/repodata/*-filelists.xml
	gzip $@/repodata/*-filelists.xml

fixtures/rpm-incomplete-other:
	rpm/gen-fixtures.sh $@ rpm/assets
	gunzip $@/repodata/*-other.xml.gz
	sed -i -e '/<package /,/<\/package>/d' $@/repodata/*-other.xml
	gzip $@/repodata/*-other.xml

fixtures/rpm-invalid-rpm:
	rpm/gen-invalid-rpm.sh $@

fixtures/rpm-invalid-updateinfo:
	rpm/gen-patched-fixtures.sh $@ rpm/invalid-updateinfo.patch

fixtures/rpm-string-version-updateinfo:
	rpm/gen-patched-fixtures.sh $@ rpm/rpm-string-version-updateinfo.patch

fixtures/rpm-long-updateinfo:
	rpm/gen-long-updateinfo.sh $@

fixtures/rpm-mirrorlist-bad:
	echo $(base_url)/fixtures/rpm-unsignedd/ > $@

fixtures/rpm-mirrorlist-good: fixtures/rpm-unsigned
	echo $(base_url)/fixtures/rpm-unsigned/ > $@

fixtures/rpm-mirrorlist-mixed: fixtures/rpm-unsigned
	echo $(base_url)/fixtures/rpm-unsigneddddd/ > $@
	echo $(base_url)/fixtures/rpm-unsignedddd/ >> $@
	echo $(base_url)/fixtures/rpm-unsigneddd/ >> $@
	echo $(base_url)/fixtures/rpm-unsignedd/ >> $@
	echo $(base_url)/fixtures/rpm-unsigned/ >> $@

fixtures/rpm-missing-filelists:
	rpm/gen-fixtures.sh $@ rpm/assets
	rm $@/repodata/*-filelists.*

fixtures/rpm-missing-other:
	rpm/gen-fixtures.sh $@ rpm/assets
	rm $@/repodata/*-other.*

fixtures/rpm-missing-primary:
	rpm/gen-fixtures.sh $@ rpm/assets
	rm $@/repodata/*-primary.*

fixtures/rpm-pkglists-updateinfo:
	rpm/gen-patched-fixtures.sh $@ rpm/pkglists-updateinfo.patch

fixtures/rpm-signed: gnupghome
	GNUPGHOME=$$(realpath -e gnupghome) rpm/gen-fixtures.sh \
		--signing-key ./rpm/GPG-RPM-PRIVATE-KEY-pulp-qe $@ rpm/assets

fixtures/rpm-unsigned:
	rpm/gen-fixtures.sh $@ rpm/assets

fixtures/rpm-packages-updateinfo: 
	rpm/gen-patched-fixtures.sh $@ rpm/updateinfo-packages.patch 

fixtures/rpm-references-updateinfo:
	rpm/gen-patched-fixtures.sh $@ rpm/references-updateinfo.patch

fixtures/rpm-richnweak-deps: fixtures/srpm-richnweak-deps
	rpm-richnweak-deps/gen-rpms.sh $@ $</*.src.rpm

fixtures/rpm-updated-updateinfo:
	rpm/gen-patched-fixtures.sh $@ rpm/updated-updateinfo.patch

fixtures/rpm-with-modules:
	rpm/gen-patched-fixtures.sh $@ rpm/modules-updateinfo.patch
	modifyrepo --mdtype=modules rpm/assets/modules.yaml "$@/repodata/"

fixtures/rpm-with-non-ascii:
	rpm/gen-rpm.sh $@ "rpm/assets-specs/$$(basename $@).spec"

# Commented out AND removed from the generation: See SATQE-3484
# fixtures/rpm-with-non-utf-8:
# 	rpm/gen-rpm.sh $@ "rpm/assets-specs/$$(basename $@).spec"

fixtures/rpm-with-sha-512:
	rpm/gen-fixtures.sh --checksum-type "sha512" $@ rpm/assets

fixtures/rpm-with-sha-1-modular:
	rpm/gen-patched-fixtures.sh $@ rpm/modules-updateinfo.patch sha1
	modifyrepo --mdtype=modules rpm/assets/modules.yaml "$@/repodata/"

fixtures/rpm-with-vendor:
	rpm/gen-rpm-and-repo.sh $@ "rpm/assets-specs/$$(basename $@).spec"

fixtures/rpm-with-pulp-distribution:
	rpm/gen-fixtures.sh $@ rpm/assets
	echo "productid" > $@/repodata/productid
	mkdir $@/release-notes
	echo "release information" > $@/release-notes/release-info
	echo "<pulp_distribution version=\"1\">" > $@/PULP_DISTRIBUTION.xml
	echo "<file>repodata/productid</file>" >> $@/PULP_DISTRIBUTION.xml
	echo "<file>release-notes/release-info</file>" >> $@/PULP_DISTRIBUTION.xml
	echo "</pulp_distribution>" >> $@/PULP_DISTRIBUTION.xml
	echo "[general]" > $@/treeinfo
	echo "arch=x86_64" >> $@/treeinfo
	echo "family=Zoo" >> $@/treeinfo
	echo "timestamp=1485887759" >> $@/treeinfo
	echo "version=42" >> $@/treeinfo

fixtures/srpm-duplicate:
	rpm-richnweak-deps/gen-srpms.sh $@/src srpm-duplicate/assets-specs/*.spec
	rpm-richnweak-deps/gen-srpms.sh $@/dst srpm-duplicate/assets-specs/*.spec
	createrepo --checksum sha256 $@

fixtures/srpm-richnweak-deps:
	rpm-richnweak-deps/gen-srpms.sh $@ rpm-richnweak-deps/assets-specs/*.spec

fixtures/srpm-signed: gnupghome
	GNUPGHOME=$$(realpath -e gnupghome) rpm/gen-fixtures.sh \
		--signing-key ./rpm/GPG-RPM-PRIVATE-KEY-pulp-qe $@ rpm/assets-srpm

fixtures/srpm-unsigned:
	rpm/gen-fixtures.sh $@ rpm/assets-srpm

gnupghome:
	install -dm700 gnupghome
	GNUPGHOME=$$(realpath -e gnupghome) gpg --import rpm/GPG-RPM-PRIVATE-KEY-pulp-qe

.PHONY: help lint lint-pylint lint-shellcheck clean all
