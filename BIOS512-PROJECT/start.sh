#!/bin/bash

docker build . -t first_container

docker run -it \
 -e USERID=1001 \
 -e GROUPID=1001 \
 -e PASSWORD="cinema123#" \
 -p 8787:8787 \
 -v $(pwd):/home/rstudio/project1 \
 first_container



