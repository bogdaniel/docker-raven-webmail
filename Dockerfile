#syntax=docker/dockerfile:1.4

# The different stages of this Dockerfile are meant to be built into separate images
# https://docs.docker.com/develop/develop-images/multistage-build/#stop-at-a-specific-build-stage
# https://docs.docker.com/compose/compose-file/#target

ARG NODE_VERSION=19
ARG ALPINE_VERSION=3.17

FROM node:${NODE_VERSION}-alpine${ALPINE_VERSION} AS configuration
MAINTAINER Bogdan Olteanu bogdan@zenchron.com
WORKDIR /srv/app

RUN apk update \
 && apk upgrade \
 && apk add --no-cache \
        ca-certificates \
 && update-ca-certificates \
    \
 # Install tools for building Haraka
 && apk add --no-cache --virtual .build-deps \
        git


RUN git clone https://github.com/ramiroaisen/raven-webmail.git ./ --branch master


FROM node:${NODE_VERSION}-alpine${ALPINE_VERSION} AS builder
MAINTAINER Bogdan Olteanu bogdan@zenchron.com
WORKDIR /srv/app

COPY --from=configuration --link /srv/app /srv/app

RUN npm i
RUN cd app && npm i
RUN cd ..
RUN npm i
RUN npm run build
RUN	node raven create-config;


FROM node:${NODE_VERSION}-alpine${ALPINE_VERSION} as app
MAINTAINER Bogdan Olteanu bogdan@zenchron.com

ENV NODE_ENV production
WORKDIR /srv/app


RUN apk add --no-cache tini

COPY --from=builder --link /srv/app /srv/app
COPY docker-entrypoint.sh /srv/app/docker-entrypoint.sh

RUN chmod +x /srv/app/docker-entrypoint.sh


ENTRYPOINT ["/sbin/tini", "--", "./docker-entrypoint.sh"]
CMD ["node", "raven.js", "start"]
