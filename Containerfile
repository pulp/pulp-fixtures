# === Build fixtures (Fedora) =================================================
FROM fedora:30 AS fedora-build

RUN dnf -yq install \
              createrepo \
              fedpkg \
              gpg \
              jq \
              make \
              ostree \
              patch \
              python3-jinja2-cli \
              rpm-build \
              rpm-sign \
              rsync

ADD . /pulp-fixtures

RUN make -C pulp-fixtures all-fedora base_url=http://BASE_URL

# === Build fixtures (Debian) =================================================
FROM debian:stretch AS debian-build

RUN apt-get update && apt-get -y install equivs reprepro

RUN mkdir -p /pulp-fixtures/fixtures
ADD Makefile /pulp-fixtures
ADD common /pulp-fixtures/common
ADD debian /pulp-fixtures/debian

RUN make -C pulp-fixtures all-debian

# === Serve content ===========================================================
FROM nginx AS server

RUN rm /usr/share/nginx/html/index.html
COPY --from=fedora-build pulp-fixtures/fixtures /usr/share/nginx/html
COPY --from=debian-build pulp-fixtures/fixtures /usr/share/nginx/html

COPY docker/assets/busybox:latest.tar /usr/share/nginx/html/docker/busybox:latest.tar
COPY puppet/assets/pulpqe-dummypuppet.tar.gz /usr/share/nginx/html/puppet/pulpqe-dummypuppet.tar.gz
COPY rpm/assets-modular/nodejs-10.15.2-1.module_f30+3181+3be24b3a.x86_64.rpm /usr/share/nginx/html/rpm-with-modular/nodejs-10.15.2-1.module_f30+3181+3be24b3a.x86_64.rpm

# use custom nginx.conf
COPY common/nginx.conf /etc/nginx/nginx.conf

EXPOSE 80

ENV BASE_URL=http://localhost:8000

ADD entrypoint.sh /
RUN chmod +x /entrypoint.sh

CMD ["./entrypoint.sh"]
