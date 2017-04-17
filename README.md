# Mán - templates rendering engine microservice
[![Deps Status](https://beta.hexfaktor.org/badge/all/github/Nebo15/man.api.svg)](https://beta.hexfaktor.org/github/Nebo15/man.api) [![Build Status](https://travis-ci.org/Nebo15/man.api.svg?branch=master)](https://travis-ci.org/Nebo15/man.api) [![Coverage Status](https://coveralls.io/repos/github/Nebo15/man.api/badge.svg?branch=master)](https://coveralls.io/github/Nebo15/man.api?branch=master) [![Ebert](https://ebertapp.io/github/Nebo15/man.api.svg)](https://ebertapp.io/github/Nebo15/man.api)

Stores templates (in `iex`, `mustache`) or `markdown` documents, renders it over HTTP API with dispatch in PDF, JSON or HTML formats.

> "Mán" translates from the Sindarin as "Spirit". Sindarin is one of the many languages spoken by the immortal Elves.

[![Build history](https://buildstats.info/travisci/chart/Nebo15/man.api)](https://travis-ci.org/Nebo15/man.api)

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

## Performance

We encourage you to perform your own tests, because synthetic results are far from real life situation. We provide them only as starting point in understanding Man's performance.

### Test environment

* MacBook Pro (15-inch, 2016)
* CPU 2,7 GHz Intel Core i7
* RAM 16 ГБ 2133 MHz LPDDR3
* Man v0.1.16 and PostgreSQL v9.6.2 running in Nebo15 Docker contianers (listed below);
* ApacheBench v2.3;
* wkhtmltopdf v0.12.4 (with patched qt).

### Results

| **Template Syntax** | Concurrency Level | Time taken for tests | Complete requests | Failed requests | Requests per second [#/sec] (mean) | Time per request | Time per request (mean, across all concurrent requests) |
| ---------------------------- | -- | -------------- | ----- | - | -------------------------- | ------------- | ----------- |
| **Mustache**                 | 50 | 8.412 seconds  | 10000 | 0 | **1188.84** | 42.058 [ms]   | 0.841 [ms]  |
| **Markdown**                 | 50 | 8.142 seconds  | 10000 | 0 | **1228.25** | 40.708 [ms]   | 0.814 [ms]  |
| **Mustache with PDF format** | 50 | 45.283 seconds | 1000  | 0 | **22.08**   | 2264.146 [ms] | 45.283 [ms] |

Full console output is available in [`pertest.md`](https://github.com/Nebo15/man.api/blob/master/docs/perftest.md).

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
