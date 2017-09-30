# First target in the Makefile is the default.
all: help

# Get the location of this makefile.
ROOT_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

# Specify the binary dependencies
REQUIRED_BINS := docker docker-compose
$(foreach bin,$(REQUIRED_BINS),\
    $(if $(shell command -v $(bin) 2> /dev/null),$(),$(error Please install `$(bin)` first!)))

.PHONY : help
help : Makefile
	@sed -n 's/^##//p' $<

## up              : Start Node
.PHONY : up
up:
	@docker-compose up -d --no-build

## down            : Shutdown Node
.PHONY : down
down:
	@docker-compose down

## restart         : Restart Node
.PHONY : restart
restart: down up

## logs            : Tail Node logs
.PHONY : logs
logs:
	@docker-compose logs -f -t | grep chainpoint-node

## logs-redis      : Tail Redis logs
.PHONY : logs-redis
logs-redis:
	@docker-compose logs -f -t | grep redis

## logs-postgres   : Tail PostgreSQL logs
.PHONY : logs-postgres
logs-postgres:
	@docker-compose logs -f -t | grep postgres

## logs-all        : Tail all logs
.PHONY : logs-all
logs-all:
	@docker-compose logs -f -t

## ps              : View running processes
.PHONY : ps
ps:
	@docker-compose ps

## build-config    : Create new `.env` config file from `.env.sample`
.PHONY : build-config
build-config:
	@[ ! -f ./.env ] && \
	cp .env.sample .env && \
	echo 'Copied config .env.sample to .env' || true

## git-pull        : Git pull latest
.PHONY : git-pull
git-pull:
	@git pull

## upgrade         : Same as `make down && git pull && make up`
.PHONY : upgrade
upgrade: down git-pull up

## postgres        : Connect to the local PostgreSQL with `psql`
.PHONY : postgres
postgres: up
	@./bin/psql

## redis           : Connect to the local Redis with `redis-cli`
.PHONY : redis
redis: up
	@./bin/redis-cli

## auth-keys       : Export HMAC authentication keys from PostgreSQL
.PHONY : auth-keys
auth-keys: up
	@echo ''
	@./bin/psql -c 'SELECT * FROM hmackey;'
