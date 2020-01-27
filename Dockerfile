# === Build fixtures (Fedora) =================================================
FROM fedora:30 AS fedora-build

RUN dnf -y install \
              git \
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

# for now, skip making docker fixtures
RUN echo "" > pulp-fixtures/docker/gen-fixtures.sh

RUN make -C pulp-fixtures fixtures

# === Build fixtures (Debian) =================================================
FROM debian:stretch AS debian-build

RUN apt-get update && apt-get -y install equivs reprepro

ADD . /pulp-fixtures

RUN make -C pulp-fixtures fixtures/debian

# === Serve content ===========================================================
FROM fedora:30 AS server

RUN dnf -y install nginx

RUN mkdir -p /usr/share/nginx/html/fixtures
COPY --from=fedora-build pulp-fixtures/fixtures /usr/share/nginx/html/fixtures
COPY --from=debian-build pulp-fixtures/fixtures /usr/share/nginx/html/fixtures

RUN echo "daemon off;" >> /etc/nginx/nginx.conf

EXPOSE 80

CMD [ "/usr/sbin/nginx" ]
