#!/bin/sh

# In CI use a variable for the image tag
docker build -f deployment/Dockerfile -t football-results:0.1.0 .
