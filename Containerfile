# === Build fixtures (Fedora) =================================================
FROM fedora:30 AS fedora-build

RUN dnf -yq install \
              createrepo \
              docker \
              fedpkg \
              gpg \
              jq \
              make \
              patch \
              puppet \
              python3-jinja2-cli \
              rpm-build \
              rpm-sign \
              rsync

ADD . /pulp-fixtures

RUN make -C pulp-fixtures all-fedora base_url=BASE_URL

# === Build fixtures (Debian) =================================================
FROM debian:stretch AS debian-build

RUN apt-get -q update && apt-get -yq install equivs reprepro

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

# turn on autoindex
RUN sed -i -e '/location \/ {/a autoindex on\;' /etc/nginx/conf.d/default.conf

EXPOSE 80

ENV BASE_URL=http://localhost:8000

ADD entrypoint.sh /
RUN chmod +x /entrypoint.sh

CMD ["./entrypoint.sh"]
