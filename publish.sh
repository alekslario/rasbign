#!/bin/bash
source ~/fun.sh

docker_login
npm version patch -f
docker build . --tag alekslario/rasbign:latest
docker push alekslario/rasbign:latest