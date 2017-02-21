# The base URL of where fixtures are hosted. The default is compatible with
# `python3 -m http.server`.
base_url=http://localhost:8000

help:
	@echo "Please use \`make <target>' where <target> is one of:"
	@echo "  help            to show this message"
	@echo "  lint            to lint the fixture generation scripts"
	@echo "  clean           to remove fixture data and 'gnupghome'"
	@echo "  fixtures        to create all fixture data"
	@echo "  fixtures/docker to create Docker fixture data"
	@echo "  fixtures/drpm-signed"
	@echo "                  to create DRPM fixtures with signed packages"
	@echo "  fixtures/drpm-unsigned"
	@echo "                  to create DRPM fixtures with unsigned packages"
	@echo "  fixtures/file   to create File fixtures"
	@echo "  fixtures/file-mixed"
	@echo "                  to create File fixtures with some not available"
	@echo "                  files on the PULP_MANIFEST"
	@echo "  fixtures/puppet to create a dummy Puppet module"
	@echo "  fixtures/python-pulp"
	@echo "                  to create a Pulp Python repository"
	@echo "  fixtures/python-pypi [base_url=...]"
	@echo "                  to create a PyPI Python repository"
	@echo "  fixtures/rpm-alt-layout"
	@echo "                  to create an RPM repository with packages in a"
	@echo "                  dedicated directory"
	@echo "  fixtures/rpm-erratum"
	@echo "                  to create a JSON erratum referencing the RPM fixtures"
	@echo "  fixtures/rpm-incomplete-filelists"
	@echo "                  to create an RPM repository with an incomplete"
	@echo "                  filelists.xml"
	@echo "  fixtures/rpm-incomplete-other"
	@echo "                  to create an RPM repository with an incomplete"
	@echo "                  other.xml"
	@echo "  fixtures/rpm-invalid-updateinfo"
	@echo "                  to create RPM fixtures with updated updateinfo.xml"
	@echo "  fixtures/rpm-mirrorlist-bad [base_url=...]"
	@echo "  fixtures/rpm-mirrorlist-good [base_url=...]"
	@echo "  fixtures/rpm-mirrorlist-mixed [base_url=...]"
	@echo "                  to create a text file referencing one or more RPM"
	@echo "                  repositories. 'bad' and 'good' reference unusable"
	@echo "                  and usable repositories, respectively, and 'mixed'"
	@echo "                  references both."
	@echo "  fixtures/rpm-missing-filelists"
	@echo "                  to create an RPM repository without filelists.xml"
	@echo "  fixtures/rpm-missing-other"
	@echo "                  to create an RPM repository without other.xml"
	@echo "  fixtures/rpm-missing-primary"
	@echo "                  to create an RPM repository without primary.xml"
	@echo "  fixtures/rpm-pkglists-updateinfo"
	@echo "                  to create RPM fixtures with multiple pkglists and"
	@echo "                  collections in updateinfo.xml"
	@echo "  fixtures/rpm-signed"
	@echo "                  to create RPM fixture data with signed packages"
	@echo "  fixtures/rpm-unsigned"
	@echo "                  to create RPM fixture data with unsigned packages"
	@echo "  fixtures/rpm-updated-updateinfo"
	@echo "                  to create RPM fixtures with invalid updateinfo.xml"
	@echo "  fixtures/rpm-with-pulp-distribution"
	@echo "                  to create an RPM repository with extra files and"
	@echo "                  a PULP_DISTRIBUTION.xml file."
	@echo "  fixtures/srpm-signed"
	@echo "                  to create SRPM fixture data with signed packages"
	@echo "  fixtures/srpm-unsigned"
	@echo "                  to create SRPM fixture data with unsigned packages"
	@echo "  gnupghome       to create a GnuPG home directory and import the"
	@echo "                  Pulp QE public key"
	@echo ""
	@echo "base_url should be set to where the fixtures will be hosted. It"
	@echo "defaults to $(base_url), for compatibility with"
	@echo "'python3 -m http.server'. It should not have a trailing slash."

clean:
	rm -rf fixtures/* gnupghome

# xargs communicates return values better than find's `-exec` argument.
lint:
	find . -name '*.sh' -print0 | xargs -0 shellcheck

all: fixtures
	$(warning The `all` target is deprecated. Use `fixtures` instead.)

fixtures: fixtures/docker \
	fixtures/drpm \
	fixtures/drpm-signed \
	fixtures/drpm-unsigned \
	fixtures/file \
	fixtures/file-mixed \
	fixtures/puppet \
	fixtures/python \
	fixtures/python-pulp \
	fixtures/python-pypi \
	fixtures/rpm \
	fixtures/rpm-alt-layout \
	fixtures/rpm-erratum \
	fixtures/rpm-incomplete-filelists \
	fixtures/rpm-incomplete-other \
	fixtures/rpm-invalid-updateinfo \
	fixtures/rpm-mirrorlist-bad \
	fixtures/rpm-mirrorlist-good \
	fixtures/rpm-mirrorlist-mixed \
	fixtures/rpm-missing-filelists \
	fixtures/rpm-missing-other \
	fixtures/rpm-missing-primary \
	fixtures/rpm-pkglists-updateinfo \
	fixtures/rpm-signed \
	fixtures/rpm-unsigned \
	fixtures/rpm-updated-updateinfo \
	fixtures/rpm-with-pulp-distribution \
	fixtures/srpm \
	fixtures/srpm-signed \
	fixtures/srpm-unsigned

fixtures/docker:
	docker/gen-fixtures.sh $@

fixtures/drpm: fixtures/drpm-signed
	$(warning The `fixtures/drpm` target is deprecated. Use `fixtures/drpm-signed` instead.)
	ln -s ./drpm-signed $@

fixtures/drpm-signed: gnupghome
	GNUPGHOME=$$(realpath -e gnupghome) rpm/gen-fixtures-delta.sh \
		--signing-key ./rpm/GPG-RPM-PRIVATE-KEY-pulp-qe $@ rpm/assets-drpm

fixtures/drpm-unsigned:
	rpm/gen-fixtures-delta.sh $@ rpm/assets-drpm

fixtures/file:
	file/gen-fixtures.sh $@

fixtures/file-mixed:
	file/gen-fixtures.sh $@
	echo missing-1.iso,4a36e4eede4a61fd547040b53b1656b6dd489bd5bc4c0dd5fe55892dcf1669e8,1048576 >> $@/PULP_MANIFEST
	echo missing-2.iso,ab6d91d4956d1a009bd6d03b3591f95aaae83b36907f77dd1ac71c400715b901,2097152 >> $@/PULP_MANIFEST

fixtures/puppet:
	puppet/gen-module.sh $@

fixtures/python: fixtures/python-pulp
	$(warning The `fixtures/python` target is deprecated. Use `fixtures/python-pulp` instead.)
	ln -s ./python-pulp $@

fixtures/python-pulp:
	cp -r python/pulp-assets $@

fixtures/python-pypi:
	python/gen-pypi-repo.sh $@ python/pypi-assets $(base_url)

fixtures/rpm: fixtures/rpm-signed
	$(warning The `fixtures/rpm` target is deprecated. Use `fixtures/rpm-signed` instead.)
	ln -s ./rpm-signed $@

fixtures/rpm-alt-layout:
	rpm/gen-fixtures.sh --packages-dir packages/keep-going $@ rpm/assets

fixtures/rpm-erratum:
	rpm/gen-erratum.sh $@ rpm/assets

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

fixtures/rpm-invalid-updateinfo:
	rpm/gen-patched-fixtures.sh $@ rpm/invalid-updateinfo.patch

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

fixtures/rpm-updated-updateinfo:
	rpm/gen-patched-fixtures.sh $@ rpm/updated-updateinfo.patch

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

fixtures/srpm: fixtures/srpm-signed
	$(warning The `fixtures/srpm` target is deprecated. Use `fixtures/srpm-signed` instead.)
	ln -s ./srpm-signed $@

fixtures/srpm-signed: gnupghome
	GNUPGHOME=$$(realpath -e gnupghome) rpm/gen-fixtures.sh \
		--signing-key ./rpm/GPG-RPM-PRIVATE-KEY-pulp-qe $@ rpm/assets-srpm

fixtures/srpm-unsigned:
	rpm/gen-fixtures.sh $@ rpm/assets-srpm

gnupghome:
	install -dm700 gnupghome
	GNUPGHOME=$$(realpath -e gnupghome) gpg --import rpm/GPG-RPM-PRIVATE-KEY-pulp-qe

.PHONY: help lint clean all
