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
	@echo "  fixtures/python-pulp"
	@echo "                  to create a Pulp Python repository"
	@echo "  fixtures/python-pypi [base_url=...]"
	@echo "                  to create a PyPI Python repository"
	@echo "  fixtures/rpm-erratum"
	@echo "                  to create a JSON erratum referencing the RPM fixtures"
	@echo "  fixtures/rpm-invalid-updateinfo"
	@echo "                  to create RPM fixtures with updated updateinfo.xml"
	@echo "  fixtures/rpm-mirrorlist-bad [base_url=...]"
	@echo "  fixtures/rpm-mirrorlist-good [base_url=...]"
	@echo "  fixtures/rpm-mirrorlist-mixed [base_url=...]"
	@echo "                  to create a text file referencing one or more RPM"
	@echo "                  repositories. 'bad' and 'good' reference unusable"
	@echo "                  and usable repositories, respectively, and 'mixed'"
	@echo "                  references both."
	@echo "  fixtures/rpm-pkglists-updateinfo"
	@echo "                  to create RPM fixtures with multiple pkglists and"
	@echo "                  collections in updateinfo.xml"
	@echo "  fixtures/rpm-signed"
	@echo "                  to create RPM fixture data with signed packages"
	@echo "  fixtures/rpm-unsigned"
	@echo "                  to create RPM fixture data with unsigned packages"
	@echo "  fixtures/rpm-updated-updateinfo"
	@echo "                  to create RPM fixtures with invalid updateinfo.xml"
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
	fixtures/python \
	fixtures/python-pulp \
	fixtures/python-pypi \
	fixtures/rpm \
	fixtures/rpm-erratum \
	fixtures/rpm-invalid-updateinfo \
	fixtures/rpm-mirrorlist-bad \
	fixtures/rpm-mirrorlist-good \
	fixtures/rpm-mirrorlist-mixed \
	fixtures/rpm-pkglists-updateinfo \
	fixtures/rpm-signed \
	fixtures/rpm-unsigned \
	fixtures/rpm-updated-updateinfo \
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

fixtures/rpm-erratum:
	rpm/gen-erratum.sh $@ rpm/assets

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

fixtures/rpm-pkglists-updateinfo:
	rpm/gen-patched-fixtures.sh $@ rpm/pkglists-updateinfo.patch

fixtures/rpm-signed: gnupghome
	GNUPGHOME=$$(realpath -e gnupghome) rpm/gen-fixtures.sh \
		--signing-key ./rpm/GPG-RPM-PRIVATE-KEY-pulp-qe $@ rpm/assets

fixtures/rpm-unsigned:
	rpm/gen-fixtures.sh $@ rpm/assets

fixtures/rpm-updated-updateinfo:
	rpm/gen-patched-fixtures.sh $@ rpm/updated-updateinfo.patch

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
