FROM fedora:30

RUN dnf -yq install \
              git \
              createrepo \
              docker \
              fedpkg \
              gpg \
              jq \
              make \
              mock \
              patch \
              puppet \
              python3-jinja2-cli \
              rpm-build \
              rpm-sign \
              rsync \
              nginx

RUN gpasswd --add "$(whoami)" mock

RUN newgrp -

ADD . /pulp-fixtures

# for now, skip making docker fixtures
RUN echo "" > pulp-fixtures/docker/gen-fixtures.sh
# also, mock doesn't seem to work in container (calls mount)
RUN echo "" > pulp-fixtures/rpm-richnweak-deps/gen-rpms.sh

RUN make -C pulp-fixtures /usr/share/nginx/html/fixtures

RUN echo "daemon off;" >> /etc/nginx/nginx.conf

EXPOSE 80

CMD [ "/usr/sbin/nginx" ]
