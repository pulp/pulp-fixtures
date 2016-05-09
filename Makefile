help:
	@echo "Please use \`make <target>' where <target> is one of:"
	@echo "  help            to show this message"
	@echo "  clean           to remove fixture data"
	@echo "  all             to execute all following targets"
	@echo "  docker-fixtures to create Docker fixture data"
	@echo "  rpm-fixtures    to create RPM fixture data"
	@echo "  rpm-updated-updateinfo-fixtures"
	@echo "                  to create RPM fixture data with updated updateinfo.xml"
	@echo "  rpm-invalid-updateinfo-fixtures"
	@echo "                  to create RPM fixture data with invalid date in updateinfo.xml"

clean:
	rm -rf ./*-fixtures

all: docker-fixtures rpm-fixtures

docker-fixtures:
	docker/gen-fixtures.sh docker-fixtures

rpm-fixtures:
	cp rpm/assets/updateinfo-base.xml rpm/assets/updateinfo.xml
	rpm/gen-fixtures.sh rpm-fixtures rpm/assets

rpm-updated-updateinfo-fixtures:
	cp rpm/assets/updateinfo-base.xml rpm/assets/updateinfo.xml
	patch rpm/assets/updateinfo.xml < rpm/assets/updateinfo-updated.patch
	rpm/gen-fixtures.sh rpm-updated-updateinfo-fixtures rpm/assets

rpm-invalid-updateinfo-fixtures:
	cp rpm/assets/updateinfo-base.xml rpm/assets/updateinfo.xml
	patch rpm/assets/updateinfo.xml < rpm/assets/updateinfo-invalid-date.patch
	rpm/gen-fixtures.sh rpm-invalid-updateinfo-fixtures rpm/assets

.PHONY: help clean all
