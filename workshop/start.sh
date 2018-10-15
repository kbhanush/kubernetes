#!/bin/bash
docker build -t worker . &&
# docker run -it -v /var/run/docker.sock:/var/run/docker.sock  -v `pwd`:/root worker /bin/bash
docker run -it -v /var/run/docker.sock:/var/run/docker.sock worker /bin/bash