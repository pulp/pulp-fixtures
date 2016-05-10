ALL = docker-fixtures \
    rpm-fixtures \
    rpm-fixtures-invalid-updateinfo \
    rpm-fixtures-updated-updateinfo

help:
	@echo "Please use \`make <target>' where <target> is one of:"
	@echo "  help            to show this message"
	@echo "  clean           to remove fixture data"
	@echo "  all             to execute all following targets"
	@echo "  docker-fixtures to create Docker fixture data"
	@echo "  rpm-fixtures    to create RPM fixture data"
	@echo "  rpm-fixtures-invalid-updateinfo"
	@echo "                  to create RPM fixtures with updated updateinfo.xml"
	@echo "  rpm-fixtures-updated-updateinfo"
	@echo "                  to create RPM fixtures with invalid updateinfo.xml"

clean:
	rm -rf $(ALL)

all: $(ALL)

docker-fixtures:
	docker/gen-fixtures.sh $@

rpm-fixtures:
	rpm/gen-fixtures.sh $@ rpm/assets

rpm-fixtures-invalid-updateinfo:
	rpm/gen-patched-fixtures.sh $@ rpm/invalid-updateinfo.patch

rpm-fixtures-updated-updateinfo:
	rpm/gen-patched-fixtures.sh $@ rpm/updated-updateinfo.patch

.PHONY: help clean all
