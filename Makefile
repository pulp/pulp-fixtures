help:
	@echo "Please use \`make <target>' where <target> is one of:"
	@echo "  help            to show this message"
	@echo "  lint            to lint the fixture generation scripts"
	@echo "  clean           to remove fixture data"
	@echo "  fixtures        to create all fixture data"
	@echo "  fixtures/docker to create Docker fixture data"
	@echo "  fixtures/drpm-unsigned"
	@echo "                  to create DRPM fixtures with unsigned packages"
	@echo "  fixtures/python to create Python fixture data"
	@echo "  fixtures/rpm    to create RPM fixture data"
	@echo "  fixtures/rpm-erratum"
	@echo "                  to create a JSON erratum referencing the RPM fixtures"
	@echo "  fixtures/rpm-invalid-updateinfo"
	@echo "                  to create RPM fixtures with updated updateinfo.xml"
	@echo "  fixtures/rpm-pkglists-updateinfo"
	@echo "                  to create RPM fixtures with multiple pkglists and"
	@echo "                  collections in updateinfo.xml"
	@echo "  fixtures/rpm-unsigned"
	@echo "                  to create RPM fixture data with unsigned packages"
	@echo "  fixtures/rpm-updated-updateinfo"
	@echo "                  to create RPM fixtures with invalid updateinfo.xml"
	@echo "  fixtures/srpm"
	@echo "                  to create SRPM fixture data"
	@echo "  fixtures/srpm-unsigned"
	@echo "                  to create SRPM fixture data with unsigned packages"

clean:
	rm -rf fixtures/*

# xargs communicates return values better than find's `-exec` argument.
lint:
	find . -name '*.sh' -print0 | xargs -0 shellcheck

all: fixtures
	$(warning The `all` target is deprecated. Use `fixtures` instead.)

fixtures: fixtures/docker \
	fixtures/drpm-unsigned \
	fixtures/python \
	fixtures/rpm \
	fixtures/rpm-erratum \
	fixtures/rpm-invalid-updateinfo \
	fixtures/rpm-pkglists-updateinfo \
	fixtures/rpm-unsigned \
	fixtures/rpm-updated-updateinfo \
	fixtures/srpm \
	fixtures/srpm-unsigned

fixtures/docker:
	docker/gen-fixtures.sh $@

fixtures/drpm-unsigned:
	rpm/gen-fixtures-delta.sh $@ rpm/assets-drpm
	rpm/del-fixtures-sign.sh $@

fixtures/python:
	python/gen-fixtures.sh $@ python/assets

fixtures/rpm:
	rpm/gen-fixtures.sh $@ rpm/assets

fixtures/rpm-erratum:
	rpm/gen-erratum.sh $@ rpm/assets

fixtures/rpm-invalid-updateinfo:
	rpm/gen-patched-fixtures.sh $@ rpm/invalid-updateinfo.patch

fixtures/rpm-pkglists-updateinfo:
	rpm/gen-patched-fixtures.sh $@ rpm/pkglists-updateinfo.patch

fixtures/rpm-unsigned:
	rpm/gen-fixtures.sh $@ rpm/assets
	rpm/del-fixtures-sign.sh $@

fixtures/rpm-updated-updateinfo:
	rpm/gen-patched-fixtures.sh $@ rpm/updated-updateinfo.patch

fixtures/srpm:
	rpm/gen-fixtures.sh $@ rpm/assets-srpm

fixtures/srpm-unsigned:
	rpm/gen-fixtures.sh $@ rpm/assets-srpm
	rpm/del-fixtures-sign.sh $@

.PHONY: help lint clean all
