#!/bin/sh

docker exec -it wordpress wp --allow-root "$@"
