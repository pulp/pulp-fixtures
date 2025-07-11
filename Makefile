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
	@echo "    all-file"
	@echo "        Create all file-related fixture data."
	@echo "    all-fedora"
	@echo "        Create all fedora-related fixture data."
	@echo "    all-debian"
	@echo "        Create all debian-related fixture data."
	@echo "    fixtures/debian"
	@echo "        Create Debian repository fixtures."
	@echo "    fixtures/debian-invalid"
	@echo "        Create invalid Debian repository fixtures."
	@echo "    fixtures/debian-complex-dists"
	@echo "        Create Debian repository fixtures with complex distribution."
	@echo "    fixtures/debian-missing-architecture"
	@echo "        Create Debian repository fixtures with missing Packages files for some architectures."
	@echo "    fixtures/debian-flat"
	@echo "        Create Debian repository fixtures in flat repository format."
	@echo "    fixtures/debian-mixed"
	@echo "        Create Debian 11 compatible repository fixtures."
	@echo "    fixtures/docker"
	@echo "        Create Docker fixture data."
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
	@echo "    fixtures/file-dl-forward"
	@echo "        Create batch-and-a-half small files."
	@echo "        Useful for deadlock-testing."
	@echo "    fixtures/file-dl-reverse"
	@echo "        Create batch-and-a-half small files, PULP_MANIFEST in reverse order."
	@echo "        Useful for deadlock-testing."
	@echo "    fixtures/file-mixed"
	@echo "        Create File fixtures with some not available files on the"
	@echo "        PULP_MANIFEST."
	@echo "    fixtures/file-manifest"
	@echo "        Create File fixtures with only a PULP_MANIFEST"
	@echo "    fixtures/ostree"
	@echo "        Create a OSTree ostree repositories."
	@echo "    fixtures/python-pypi [base_url=...]"
	@echo "        Create a PyPI Python repository."
	@echo "    fixtures/rpm-advisory-incomplete-package-list"
	@echo "        Create an RPM repository with advisory with incomplete package list."
	@echo "    fixtures/rpm-advisory-diff-repo"
	@echo "        Create an RPM repository with advisory with different package list."
	@echo "    fixtures/rpm-alt-layout"
	@echo "        Create an RPM repository with packages in a dedicated"
	@echo "        directory."
	@echo "    fixtures/rpm-advisory-no-update-date"
	@echo "        Create an RPM repository with advisory without updated date."
	@echo "	   fixtures/rpm-custom-repo-metadata"
	@echo "        Create an RPM repository with repository metadata."
	@echo "	   fixtures/rpm-custom-repo-metadata-changed"
	@echo "        Create an RPM repository with changed repository metadata but same revision number."
	@echo "    fixtures/rpm-distribution-tree"
	@echo "        Create an RPM repository with distribution tree."
	@echo "    fixtures/rpm-distribution-tree-metadata-only"
	@echo "        Create an RPM repository with distribution tree metadata only."
	@echo "    fixtures/rpm-distribution-tree-empty-root"
	@echo "        Create an RPM repository with distribution tree metadata only - and no root repodata at all."
	@echo "    fixtures/rpm-with-modules"
	@echo "        Create an RPM repository with modules"
	@echo "    fixtures/rpm-with-modules-modified"
	@echo "        Create an RPM repository with modules but without some dependencies."
	@echo "    fixtures/rpm-modular"
	@echo "        Create an RPM repository with modules, module defaults and module obsoletes."
	@echo "    fixtures/rpm-modules-static-context"
	@echo "        Create RPM Modules fixture data with static_context entries."
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
	@echo "    fixtures/rpm-unsigned-meta-only"
	@echo "         Creates RPM fixture with metadata only."
	@echo "    fixtures/rpm-unsigned-modified"
	@echo "        Create RPM fixture without the whale package."
	@echo "    fixtures/rpm-updated-updateinfo"
	@echo "        Create RPM fixtures with updated updateinfo.xml."
	@echo "    fixtures/rpm-with-md5"
	@echo "        Create RPM fixture data with checksum as 'md5'."
	@echo "    fixtures/rpm-with-sha"
	@echo "        Create RPM fixture data with checksum as 'sha'."
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
	@echo "    fixtures/rpm-zchunk"
	@echo "        Create an RPM repository with zchunk metadata."
	@echo "    fixtures/rpm-zstd-metadata"
	@echo "        Create an RPM repository with zstd-compressed metadata."
	@echo "    fixtures/rpm-no-comps"
	@echo "        Create an RPM repository without comps.xml package groups."
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
	@echo "        Create a GnuPG home directory and import the pulp-fixture-signing-key public"
	@echo "        key."
	@echo ""
	@echo "base_url should be set to where the fixtures will be hosted. It"
	@echo "defaults to $(base_url), for compatibility with 'python3 -m"
	@echo "http.server'. It should not have a trailing slash."

clean:
	rm -rf fixtures gnupghome

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

all: all-skipped all-debian all-fedora
	$(warning The `all` target is deprecated. Use `all-fedora` or `all-debian` instead.)

# for now, skip making docker fixtures
all-skipped: \
	fixtures/docker \

all-debian: \
	fixtures/debian \
	fixtures/debian-invalid \
	fixtures/debian-complex-dists \
	fixtures/debian-missing-architecture \
	fixtures/debian-flat \
	fixtures/debian-mixed \
	fixtures/gem \

all-fedora: \
	fixtures/diff-name-same-content \
	fixtures/file \
	fixtures/file-chunked \
	fixtures/file-dl-forward \
	fixtures/file-dl-reverse \
	fixtures/file-invalid \
	fixtures/file-large \
	fixtures/file-manifest \
	fixtures/file-many \
	fixtures/file-mixed \
	fixtures/file-perf \
	fixtures/file2 \
	fixtures/ostree \
	fixtures/python-pypi \
	fixtures/rpm-advisory-diff-repo \
	fixtures/rpm-advisory-diffpkgs \
	fixtures/rpm-advisory-incomplete-package-list \
	fixtures/rpm-advisory-no-update-date \
	fixtures/rpm-alt-layout \
	fixtures/rpm-complex-pkg \
	fixtures/rpm-custom-repo-metadata \
	fixtures/rpm-custom-repo-metadata-changed \
	fixtures/rpm-distribution-tree \
	fixtures/rpm-distribution-tree-changed-addon \
	fixtures/rpm-distribution-tree-changed-main \
	fixtures/rpm-distribution-tree-changed-variant \
	fixtures/rpm-distribution-tree-metadata-only \
	fixtures/rpm-distribution-tree-empty-root \
	fixtures/rpm-incomplete-filelists \
	fixtures/rpm-incomplete-other \
	fixtures/rpm-invalid-rpm \
	fixtures/rpm-invalid-updateinfo \
	fixtures/rpm-long-updateinfo \
	fixtures/rpm-mirrorlist-bad \
	fixtures/rpm-mirrorlist-good \
	fixtures/rpm-mirrorlist-mixed \
	fixtures/rpm-missing-filelists \
	fixtures/rpm-missing-other \
	fixtures/rpm-missing-primary \
	fixtures/rpm-modular \
	fixtures/rpm-modules-static-context \
	fixtures/rpm-packages-updateinfo \
	fixtures/rpm-pkglists-updateinfo \
	fixtures/rpm-references-updateinfo \
	fixtures/rpm-richnweak-deps \
	fixtures/rpm-signed \
	fixtures/rpm-string-version-updateinfo \
	fixtures/rpm-unsigned \
	fixtures/rpm-unsigned-meta-only \
	fixtures/rpm-unsigned-modified \
	fixtures/rpm-updated-updateinfo \
	fixtures/rpm-updated-updateversion \
	fixtures/rpm-with-md5 \
	fixtures/rpm-with-modules \
	fixtures/rpm-with-modules-modified \
	fixtures/rpm-with-non-ascii \
	fixtures/rpm-with-non-utf-8 \
	fixtures/rpm-with-pulp-distribution \
	fixtures/rpm-with-sha \
	fixtures/rpm-with-sha-1-modular \
	fixtures/rpm-with-sha-512 \
	fixtures/rpm-with-vendor \
	fixtures/rpm-zstd-metadata \
	fixtures/rpm-no-comps \
	fixtures/srpm-duplicate \
	fixtures/srpm-richnweak-deps \
	fixtures/srpm-signed \
	fixtures/srpm-unsigned

all-file: \
	fixtures/file \
	fixtures/file2 \
	fixtures/file-invalid \
	fixtures/file-large \
	fixtures/file-many \
	fixtures/file-perf \
	fixtures/file-dl-forward \
	fixtures/file-dl-reverse \
	fixtures/file-mixed \
	fixtures/file-manifest

gnupghome:
	install -dm700 $@
	GNUPGHOME=$$(realpath -e gnupghome) gpg --import common/GPG-PRIVATE-KEY-fixture-signing

fixtures:
	mkdir -p $@

fixtures/debian: fixtures gnupghome
	GNUPGHOME=$$(realpath -e gnupghome) debian/gen-fixtures.sh $@

fixtures/debian-invalid: fixtures fixtures/debian
	debian/gen-invalid-fixtures.sh $@

fixtures/debian-complex-dists: fixtures gnupghome
	GNUPGHOME=$$(realpath -e gnupghome) debian/gen_complex_dists_fixtures.sh $@

fixtures/debian-missing-architecture: fixtures gnupghome
	GNUPGHOME=$$(realpath -e gnupghome) debian/gen-missing-architecture-fixtures.sh $@

fixtures/debian-flat: fixtures
	debian/gen-flat-repo-fixtures.sh $@

fixtures/debian-mixed: fixtures gnupghome
	GNUPGHOME=$$(realpath -e gnupghome) debian/gen-mixed-fixtures.sh $@

fixtures/docker: fixtures
	docker/gen-fixtures.sh $@

fixtures/file: fixtures
	file/gen-fixtures.sh $@

fixtures/file-chunked: fixtures
	file/gen-chunked-fixtures.sh $@

fixtures/file2: fixtures
	file/gen-fixtures.sh $@

fixtures/file-invalid: fixtures
	file/gen-fixtures.sh $@
	echo 'blah' > $@/4.iso
	echo 4.iso,4a36e4eede4a61fd547040b53b1656b6dd489bd5bc4c0dd5fe55892dcf1669e8,1048576 >> $@/PULP_MANIFEST

fixtures/file-large: fixtures
	file/gen-fixtures.sh $@ --number 10 --file-size 10M

fixtures/file-many: fixtures
	file/gen-fixtures.sh $@ --number 250

fixtures/file-perf: fixtures
	# 100,000 files were exceeding Travis' 50 minute time limit
	# https://pulp.plan.io/issues/6104
	# file/gen-fixtures.sh $@ --number 100000 --file-size 50
	file/gen-fixtures.sh $@ --number 20000 --file-size 50

fixtures/file-dl-forward: fixtures
	file/gen-fixtures.sh $@ --number 750 --file-size 50

fixtures/file-dl-reverse: fixtures
	file/gen-fixtures.sh $@ --number 750 --file-size 50 --reverse

fixtures/file-mixed: fixtures
	file/gen-fixtures.sh $@
	echo missing-1.iso,4a36e4eede4a61fd547040b53b1656b6dd489bd5bc4c0dd5fe55892dcf1669e8,1048576 >> $@/PULP_MANIFEST
	echo missing-2.iso,ab6d91d4956d1a009bd6d03b3591f95aaae83b36907f77dd1ac71c400715b901,2097152 >> $@/PULP_MANIFEST

fixtures/file-manifest: fixtures/file
	mkdir -p $@
	cp fixtures/file/PULP_MANIFEST $@/PULP_MANIFEST

fixtures/gem: fixtures
	gem/gen-fixtures.sh $@

fixtures/ostree: fixtures
	ostree/gen-fixtures.sh $@/small

fixtures/python-pypi: fixtures
	python/gen-pypi-repo.sh $@ python/pypi-assets $(base_url)

fixtures/rpm-advisory-incomplete-package-list: fixtures
	rpm/gen-patched-fixtures.sh -d $@ -f rpm/advisory-incomplete-package-list.patch

fixtures/rpm-advisory-diffpkgs: fixtures
	rpm/gen-patched-fixtures.sh -d $@ -f rpm/advisory-diffpkgs.patch

fixtures/rpm-advisory-diff-repo: fixtures
	rpm/gen-patched-fixtures.sh -d $@ -f rpm/advisory-diff-repo.patch

fixtures/rpm-advisory-no-update-date: fixtures
	rpm/gen-patched-fixtures.sh -d $@ -f rpm/advisory-no-update-date.patch

fixtures/rpm-complex-pkg: fixtures
	sh rpm-new/build_repos.sh $@

fixtures/rpm-custom-repo-metadata: fixtures
	rpm/gen-fixtures.sh ./fixtures/rpm-repo-metadata rpm/assets
	modifyrepo_c --no-compress --mdtype=productid ./rpm/custom_metadata ./fixtures/rpm-repo-metadata/repodata/
	sed -i 's#<revision>.*#<revision>1234567890</revision>#' ./fixtures/rpm-repo-metadata/repodata/repomd.xml

fixtures/rpm-custom-repo-metadata-changed: fixtures
	rpm/gen-fixtures.sh ./fixtures/rpm-repo-metadata-changed rpm/assets
	echo "Change in custom repository metadata." >> ./rpm/custom_metadata
	modifyrepo_c --no-compress --mdtype=productid ./rpm/custom_metadata ./fixtures/rpm-repo-metadata-changed/repodata/
	sed -i 's#<revision>.*#<revision>1234567890</revision>#' ./fixtures/rpm-repo-metadata-changed/repodata/repomd.xml

fixtures/rpm-distribution-tree: fixtures gnupghome fixtures/rpm-signed
	cp -R ./rpm/assets-distributiontree ./fixtures/rpm-distribution-tree
	mkdir -p ./fixtures/rpm-distribution-tree/addons/dolphin
	mkdir ./fixtures/rpm-distribution-tree/addons/whale
	mkdir -p ./fixtures/rpm-distribution-tree/variants/land
	rpm/gen-fixtures.sh ./fixtures/rpm-distribution-tree/addons/dolphin rpm/assets-pkg-dolphin
	rpm/gen-fixtures.sh ./fixtures/rpm-distribution-tree/addons/whale rpm/assets-pkg-whale
	rpm/gen-fixtures.sh ./fixtures/rpm-distribution-tree/variants/land rpm/assets-pkg-lion
	rpm/gen-fixtures.sh --packages-dir Packages $@ rpm/assets-pkg-shark

fixtures/rpm-distribution-tree-changed-addon: fixtures gnupghome fixtures/rpm-signed
	ln -s ../assets-srpm/test-srpm02-1.0-1.src.rpm ./rpm/assets-pkg-dolphin/test-srpm02-1.0-1.src.rpm
	cp -R ./rpm/assets-distributiontree ./fixtures/rpm-distribution-tree-changed-addon
	mkdir -p ./fixtures/rpm-distribution-tree-changed-addon/addons/dolphin
	mkdir ./fixtures/rpm-distribution-tree-changed-addon/addons/whale
	mkdir -p ./fixtures/rpm-distribution-tree-changed-addon/variants/land
	rpm/gen-fixtures.sh ./fixtures/rpm-distribution-tree-changed-addon/addons/dolphin rpm/assets-pkg-dolphin
	rpm/gen-fixtures.sh ./fixtures/rpm-distribution-tree-changed-addon/addons/whale rpm/assets-pkg-whale
	rpm/gen-fixtures.sh ./fixtures/rpm-distribution-tree-changed-addon/variants/land rpm/assets-pkg-lion
	rpm/gen-fixtures.sh --packages-dir Packages $@ rpm/assets-pkg-shark
	rm -f ./rpm/assets-pkg-dolphin/test-srpm02-1.0-1.src.rpm

fixtures/rpm-distribution-tree-changed-main: fixtures gnupghome fixtures/rpm-signed
	ln -s ../assets-srpm/test-srpm01-1.0-1.src.rpm ./rpm/assets-pkg-shark/test-srpm01-1.0-1.src.rpm
	cp -R ./rpm/assets-distributiontree ./fixtures/rpm-distribution-tree-changed-main
	mkdir -p ./fixtures/rpm-distribution-tree-changed-main/addons/dolphin
	mkdir ./fixtures/rpm-distribution-tree-changed-main/addons/whale
	mkdir -p ./fixtures/rpm-distribution-tree-changed-main/variants/land
	rpm/gen-fixtures.sh ./fixtures/rpm-distribution-tree-changed-main/addons/dolphin rpm/assets-pkg-dolphin
	rpm/gen-fixtures.sh ./fixtures/rpm-distribution-tree-changed-main/addons/whale rpm/assets-pkg-whale
	rpm/gen-fixtures.sh ./fixtures/rpm-distribution-tree-changed-main/variants/land rpm/assets-pkg-lion
	rpm/gen-fixtures.sh --packages-dir Packages $@ rpm/assets-pkg-shark
	rm -f ./rpm/assets-pkg-shark/test-srpm01-1.0-1.src.rpm

fixtures/rpm-distribution-tree-changed-variant: fixtures gnupghome fixtures/rpm-signed
	ln -s ../assets-srpm/test-srpm03-1.0-1.src.rpm ./rpm/assets-pkg-lion/test-srpm03-1.0-1.src.rpm
	cp -R ./rpm/assets-distributiontree ./fixtures/rpm-distribution-tree-changed-variant
	mkdir -p ./fixtures/rpm-distribution-tree-changed-variant/addons/dolphin
	mkdir ./fixtures/rpm-distribution-tree-changed-variant/addons/whale
	mkdir -p ./fixtures/rpm-distribution-tree-changed-variant/variants/land
	rpm/gen-fixtures.sh ./fixtures/rpm-distribution-tree-changed-variant/addons/dolphin rpm/assets-pkg-dolphin
	rpm/gen-fixtures.sh ./fixtures/rpm-distribution-tree-changed-variant/addons/whale rpm/assets-pkg-whale
	rpm/gen-fixtures.sh ./fixtures/rpm-distribution-tree-changed-variant/variants/land rpm/assets-pkg-lion
	rpm/gen-fixtures.sh --packages-dir Packages $@ rpm/assets-pkg-shark
	rm -f ./rpm/assets-pkg-lion/test-srpm03-1.0-1.src.rpm

fixtures/rpm-distribution-tree-metadata-only: fixtures/rpm-distribution-tree
	mkdir -p $@/addons/dolphin
	mkdir -p $@/addons/whale
	mkdir -p $@/variants/land
	cp -R fixtures/rpm-distribution-tree/.treeinfo $@/
	cp -R fixtures/rpm-distribution-tree/repodata $@/
	cp -R fixtures/rpm-distribution-tree/addons/dolphin/repodata $@/addons/dolphin/
	cp -R fixtures/rpm-distribution-tree/addons/whale/repodata $@/addons/whale/
	cp -R fixtures/rpm-distribution-tree/variants/land/repodata $@/variants/land/

fixtures/rpm-distribution-tree-empty-root: fixtures gnupghome fixtures/rpm-signed
	cp -R ./rpm/assets-distributiontree ./fixtures/rpm-distribution-tree-empty-root
	mkdir -p ./fixtures/rpm-distribution-tree-empty-root/addons/dolphin
	mkdir ./fixtures/rpm-distribution-tree-empty-root/addons/whale
	mkdir -p ./fixtures/rpm-distribution-tree-empty-root/variants/land
	rpm/gen-fixtures.sh ./fixtures/rpm-distribution-tree/addons/dolphin rpm/assets-pkg-dolphin
	rpm/gen-fixtures.sh ./fixtures/rpm-distribution-tree/addons/whale rpm/assets-pkg-whale
	rpm/gen-fixtures.sh ./fixtures/rpm-distribution-tree/variants/land rpm/assets-pkg-lion

fixtures/rpm-alt-layout: fixtures
	rpm/gen-fixtures.sh --packages-dir packages/keep-going $@ rpm/assets

fixtures/rpm-incomplete-filelists: fixtures
	rpm/gen-fixtures.sh $@ rpm/assets
	gunzip $@/repodata/*-filelists.xml.gz
	sed -i -e '/<package /,/<\/package>/d' $@/repodata/*-filelists.xml
	gzip $@/repodata/*-filelists.xml

fixtures/rpm-incomplete-other: fixtures
	rpm/gen-fixtures.sh $@ rpm/assets
	gunzip $@/repodata/*-other.xml.gz
	sed -i -e '/<package /,/<\/package>/d' $@/repodata/*-other.xml
	gzip $@/repodata/*-other.xml

fixtures/rpm-invalid-rpm: fixtures
	rpm/gen-invalid-rpm.sh $@

fixtures/rpm-invalid-updateinfo: fixtures
	rpm/gen-patched-fixtures.sh -d $@ -f rpm/invalid-updateinfo.patch

fixtures/rpm-string-version-updateinfo: fixtures
	rpm/gen-patched-fixtures.sh -d $@ -f rpm/rpm-string-version-updateinfo.patch

fixtures/rpm-long-updateinfo: fixtures
	rpm/gen-long-updateinfo.sh $@

fixtures/rpm-mirrorlist-bad: fixtures
	echo $(base_url)/rpm-unsignedd/ > $@

fixtures/rpm-mirrorlist-good: fixtures fixtures/rpm-unsigned
	echo $(base_url)/rpm-unsigned/ > $@

fixtures/rpm-mirrorlist-mixed: fixtures fixtures/rpm-unsigned
	echo $(base_url)/rpm-unsigneddddd/ > $@
	echo $(base_url)/rpm-unsignedddd/ >> $@
	echo $(base_url)/rpm-unsigneddd/ >> $@
	echo $(base_url)/rpm-unsignedd/ >> $@
	echo $(base_url)/rpm-unsigned/ >> $@

fixtures/rpm-missing-filelists: fixtures
	rpm/gen-fixtures.sh $@ rpm/assets
	rm $@/repodata/*-filelists.*

fixtures/rpm-missing-other: fixtures
	rpm/gen-fixtures.sh $@ rpm/assets
	rm $@/repodata/*-other.*

fixtures/rpm-missing-primary: fixtures
	rpm/gen-fixtures.sh $@ rpm/assets
	rm $@/repodata/*-primary.*

fixtures/rpm-pkglists-updateinfo: fixtures
	rpm/gen-patched-fixtures.sh -d $@ -f rpm/pkglists-updateinfo.patch

fixtures/rpm-signed: fixtures gnupghome
	GNUPGHOME=$$(realpath -e gnupghome) rpm/gen-fixtures.sh \
		--signing-key ./common/GPG-PRIVATE-KEY-fixture-signing $@ rpm/assets

fixtures/rpm-unsigned: fixtures
	rpm/gen-fixtures.sh $@ rpm/assets

fixtures/rpm-zstd-metadata: fixtures
	rpm/gen-fixtures.sh $@ rpm/assets
	createrepo_c --general-compress-type=zstd --update $@

fixtures/rpm-no-comps: fixtures
	mkdir -p $@
	cp rpm/assets/* $@/
	rm $@/comps.xml
	rm $@/modules.yaml
	rpm/gen-fixtures.sh $@ fixtures/rpm-no-comps

fixtures/rpm-unsigned-meta-only: fixtures fixtures/rpm-unsigned
	mkdir -p $@
	cp -R fixtures/rpm-unsigned/repodata $@/

fixtures/rpm-unsigned-modified: fixtures
	rpm/gen-fixtures.sh $@ rpm/assets
	rm $@/whale-0.2-1.noarch.rpm
	createrepo_c --general-compress-type gz --update $@

fixtures/rpm-packages-updateinfo: fixtures
	rpm/gen-patched-fixtures.sh -d $@ -f rpm/updateinfo-packages.patch

fixtures/rpm-references-updateinfo: fixtures
	rpm/gen-patched-fixtures.sh -d $@ -f rpm/references-updateinfo.patch

fixtures/rpm-richnweak-deps: fixtures/srpm-richnweak-deps fixtures
	rpm-richnweak-deps/gen-rpms.sh $@ $</*.src.rpm

fixtures/rpm-updated-updateinfo: fixtures
	rpm/gen-patched-fixtures.sh -d $@ -f rpm/updated-updateinfo.patch

fixtures/rpm-updated-updateversion: fixtures
	rpm/gen-patched-fixtures.sh -d $@ -f rpm/updated-updateversion.patch

fixtures/rpm-with-md5: fixtures
	rpm/gen-fixtures.sh --checksum-type "md5" $@ rpm/assets

fixtures/rpm-with-sha: fixtures
	rpm/gen-fixtures.sh --checksum-type "sha" --productid $@ rpm/assets

fixtures/rpm-modular: fixtures
	rpm/gen-fixtures.sh $@ rpm/assets-modularity
	modifyrepo_c --mdtype=modules rpm/assets-modularity/modules.yaml "$@/repodata/"

fixtures/rpm-with-modules: fixtures
	rpm/gen-patched-fixtures.sh -d $@ -f rpm/modules-updateinfo.patch
	modifyrepo_c --mdtype=modules rpm/assets/modules.yaml "$@/repodata/"

fixtures/rpm-with-modules-modified: fixtures
	rpm/gen-patched-fixtures.sh -d $@ -f rpm/modules-updateinfo.patch
	rm $@/kangaroo-0.3-1.noarch.rpm
	rm $@/shark-0.1-1.noarch.rpm
	rm $@/stork-0.12-2.noarch.rpm
	createrepo_c --general-compress-type gz --update $@
	modifyrepo_c --mdtype=modules rpm/assets/modules.yaml "$@/repodata/"

fixtures/rpm-modules-static-context: fixtures
	rpm/gen-patched-fixtures.sh -d $@ -f rpm/modules-static-context.patch -t module -a rpm/assets-modularity

fixtures/rpm-with-non-ascii: fixtures
	rpm/gen-rpm.sh $@ "rpm/assets-specs/$$(basename $@).spec"

# See SATQE-3484
fixtures/rpm-with-non-utf-8: fixtures
	cp -R ./rpm/assets-non-utf-8 ./fixtures/rpm-with-non-utf-8
# 	rpm/gen-rpm.sh $@ "rpm/assets-specs/$$(basename $@).spec"

fixtures/rpm-with-sha-512: fixtures
	rpm/gen-fixtures.sh --checksum-type "sha512" $@ rpm/assets

fixtures/rpm-with-sha-1-modular: fixtures
	rpm/gen-patched-fixtures.sh -d $@ -f rpm/modules-updateinfo.patch -s sha1
	modifyrepo_c --mdtype=modules rpm/assets/modules.yaml "$@/repodata/"

fixtures/rpm-with-vendor: fixtures
	rpm/gen-rpm-and-repo.sh $@ "rpm/assets-specs/$$(basename $@).spec"

fixtures/rpm-with-pulp-distribution: fixtures
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

fixtures/rpm-zchunk: fixtures
	rpm/gen-fixtures.sh --zchunk $@ rpm/assets

fixtures/srpm-duplicate: fixtures
	rpm-richnweak-deps/gen-srpms.sh $@/src srpm-duplicate/assets-specs/*.spec
	rpm-richnweak-deps/gen-srpms.sh $@/dst srpm-duplicate/assets-specs/*.spec
	createrepo_c --general-compress-type gz $@

fixtures/srpm-richnweak-deps: fixtures
	rpm-richnweak-deps/gen-srpms.sh $@ rpm-richnweak-deps/assets-specs/*.spec

fixtures/srpm-signed: fixtures gnupghome
	GNUPGHOME=$$(realpath -e gnupghome) rpm/gen-fixtures.sh \
		--signing-key ./common/GPG-PRIVATE-KEY-fixture-signing $@ rpm/assets-srpm

fixtures/srpm-unsigned: fixtures
	rpm/gen-fixtures.sh $@ rpm/assets-srpm

fixtures/diff-name-same-content: fixtures
	rpm/gen-fixtures.sh $@ rpm/assets-diff-name-same-content

.PHONY: help lint lint-pylint lint-shellcheck clean all all-skipped all-debian all-fedora
