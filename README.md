# Mán
[![Deps Status](https://beta.hexfaktor.org/badge/all/github/Nebo15/man.api.svg)](https://beta.hexfaktor.org/github/Nebo15/man.api) [![Build Status](https://travis-ci.org/Nebo15/man.api.svg?branch=master)](https://travis-ci.org/Nebo15/man.api) [![Coverage Status](https://coveralls.io/repos/github/Nebo15/man.api/badge.svg?branch=master)](https://coveralls.io/github/Nebo15/man.api?branch=master) [![Ebert](https://ebertapp.io/github/Nebo15/man.api.svg)](https://ebertapp.io/github/Nebo15/man.api)

Mán - templates rendering as a service.

[![Build history](https://buildstats.info/travisci/chart/Nebo15/man.api)](https://travis-ci.org/Nebo15/man.api)

It is capable to store templates (in `iex`, `mustache`) or `markdown`, render it and dispatch in PDF, JSON or HTML formats.

> "Mán" translates from the Sindarin as "Spirit". Sindarin is one of the many languages spoken by the immortal Elves.

## Docs

Full API and installation description available on [dedicated page](http://docs.man2.apiary.io/).

## Introduction

Man consists of two main parts:

- REST API back-end that allows to manage and render Templates;
- Management UI that simplifies configuration and management.

## Use Cases

- Rendering reports;
- Central control over Email or/and SMS templates;
- PDF/HTML printout forms generation;
- Rendering HTML pages over API.

## UI

> Screenshots

## Perfomance

## Setup Guide

### Docker

Easiest way to deploy Man is to use docker containers.
We constantly are releasing pre-built versions that will reduce time to deploy:

- [Back-End Docker container](https://hub.docker.com/r/nebo15/man/);
- [PostgreSQL Docker container](https://hub.docker.com/r/nebo15/alpine-postgre/);
- [UI Docker container](https://hub.docker.com/r/nebo15/man-web/).

### Heroku

Template allows to deploy Man to Heroku just in minute (and use it for free within Heroku tiers):

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy?template=https://github.com/nebo15/man.api)
