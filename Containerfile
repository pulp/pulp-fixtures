# === Build fixtures (Fedora) =================================================
FROM registry.fedoraproject.org/fedora:40 AS fedora-build

RUN dnf -yq install \
              fedpkg \
              gpg \
              jq \
              make \
              ostree \
              patch \
              python3-pip \
              python3-jinja2-cli \
              rpm-build \
              rpm-sign \
              rsync

# the default createrepo_c provided by Fedora has legacy hashes disabled, the one
# on PyPI does not (because we need it)
RUN pip install createrepo_c==1.2.0
ADD . /pulp-fixtures

RUN make -C pulp-fixtures all-fedora base_url=http://BASE_URL

# === Build fixtures (Debian) =================================================
FROM debian:bullseye AS debian-build

RUN apt-get update
RUN apt-get -y install \
              equivs \
              reprepro \
              dpkg-dev \
              apt-utils \
              ruby

RUN mkdir -p /pulp-fixtures/fixtures
ADD Makefile /pulp-fixtures
ADD common /pulp-fixtures/common
ADD debian /pulp-fixtures/debian
ADD gem /pulp-fixtures/gem

RUN make -C pulp-fixtures all-debian

# === Serve content ===========================================================
FROM registry.access.redhat.com/ubi8/ubi AS server

RUN dnf install -y nginx && dnf clean all
RUN rm /usr/share/nginx/html/index.html
COPY --from=fedora-build pulp-fixtures/fixtures /usr/share/nginx/html
COPY --from=debian-build pulp-fixtures/fixtures /usr/share/nginx/html

COPY docker/assets/busybox:latest.tar /usr/share/nginx/html/docker/busybox:latest.tar
COPY rpm/assets-modular/nodejs-10.15.2-1.module_f30+3181+3be24b3a.x86_64.rpm /usr/share/nginx/html/rpm-with-modular/nodejs-10.15.2-1.module_f30+3181+3be24b3a.x86_64.rpm

# use custom nginx.conf
COPY common/nginx.conf /etc/nginx/nginx.conf
EXPOSE 8080

ADD entrypoint.sh /
RUN chmod +x /entrypoint.sh
RUN NO_NGINX=0 ./entrypoint.sh
CMD ["./entrypoint.sh"]
