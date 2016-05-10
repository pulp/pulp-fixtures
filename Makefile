ALL = docker-fixtures rpm-fixtures

help:
	@echo "Please use \`make <target>' where <target> is one of:"
	@echo "  help            to show this message"
	@echo "  clean           to remove fixture data"
	@echo "  all             to execute all following targets"
	@echo "  docker-fixtures to create Docker fixture data"
	@echo "  rpm-fixtures    to create RPM fixture data"

clean:
	rm -rf $(ALL)

all: $(ALL)

docker-fixtures:
	docker/gen-fixtures.sh $@

rpm-fixtures:
	rpm/gen-fixtures.sh $@ rpm/assets

.PHONY: help clean all
