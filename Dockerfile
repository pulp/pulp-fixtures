FROM fedora:30

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
              rsync \
              nginx

ADD . /pulp-fixtures

# for now, skip making docker fixtures
RUN echo "" > pulp-fixtures/docker/gen-fixtures.sh

RUN make -C pulp-fixtures fixtures

RUN cp -R pulp-fixtures/fixtures /usr/share/nginx/html/

RUN echo "daemon off;" >> /etc/nginx/nginx.conf

EXPOSE 80

CMD [ "/usr/sbin/nginx" ]
