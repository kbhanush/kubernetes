#!/bin/bash
docker build -t worker . &&
docker run -it -v /var/run/docker.sock:/var/run/docker.sock  -v `pwd`:/opt/oracle worker /bin/bash
