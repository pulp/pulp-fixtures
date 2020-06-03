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

RUN make -C pulp-fixtures all-fedora

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

RUN mkdir -p /usr/share/nginx/html/fixtures
COPY --from=fedora-build pulp-fixtures/fixtures /usr/share/nginx/html/fixtures
COPY --from=debian-build pulp-fixtures/fixtures /usr/share/nginx/html/fixtures

# turn on autoindex
RUN sed -i -e '/location.*\/.*{/a autoindex on\;' /etc/nginx/conf.d/default.conf

# remove the index page
RUN rm /usr/share/nginx/html/index.html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
