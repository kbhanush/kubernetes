#!/bin/bash
docker build -t worker . &&
# Production run on Mac
# change database/wallet to database
docker run -it -v /var/run/docker.sock:/var/run/docker.sock worker /bin/bash

# Production run on Windows
# TODO

# Dev Run
# docker run -it -v /var/run/docker.sock:/var/run/docker.sock -v `pwd`:/opt/oracle worker /bin/bash
