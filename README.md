# JumpInChat deployment scripts

## Getting started

Requires docker and docker-compose

## Services list

* [srv](./srv): Web and chat client server
* [home](./home): Home page, directory and user settings site
* [janus](./janus): media server config
* [mongodb](./mongodb): mongodb database config
* [nginx](./nginx): nginx config
* [haproxy](./haproxy): load balancer proxy config

Also required is [jumpinchat/jumpinchat-emails](https://github.com/jumpinchat/jumpinchat-email) for the email service

## How to use

### Running Janus locally

```shell
  docker-compose -f docker-compose.yml -f local-compose.yml up -d janus && dc logs -f janus
```

### Run all services

You will need to update the compose file with the appropriate secrets

```shell
  docker-compose up
```

Since MongoDB replication is used, you'll have to set that up by running `./initMongoRepl.sh`

## Publishing packages

Since I used a privately hosted docker registry, you will have to update the image URLs in `docker-compose.yml` with your own, or a public registry

```yaml
  # e.g.
  web:
    image: registry.example.com/<user>/web
```

then push them

```shell
  docker push registry.example.com/<user>/web:<tag>
```

It's best to do this if you plan on hosting efficiently on a remote server, to avoid having to build containers
on the server itself.
