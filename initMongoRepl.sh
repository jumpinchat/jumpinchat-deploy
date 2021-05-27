#!/bin/bash

docker-compose exec mongodb mongo "rs.initiate()"
docker-compose exec mongodb mongo "rs.add('mongodbslave')"
