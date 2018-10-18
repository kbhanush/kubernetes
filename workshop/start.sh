#!/bin/bash
docker build -t worker . &&
# Production run on Mac
docker run -it -v /var/run/docker.sock:/var/run/docker.sock -v `pwd`/database/wallet:/opt/oracle/database/wallet worker /bin/bash

# Production run on Windows
# TODO

# Dev Run
# docker run -it -v /var/run/docker.sock:/var/run/docker.sock -v `pwd`:/opt/oracle/app worker /bin/bash
