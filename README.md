This repository contains the components necessary to create a basic Docker
container for [ODK Aggregate](https://opendatakit.org/use/aggregate/) paired
with MySQL. The image is based on a Tomcat6 image, and bundles an ODK Aggregate
build retrieved February 2016.

## TODO

As an alternative to bundling an ODK Aggregate WAR with this Docker image, it
would be preferable to download a specific version as part of the build. It
should also be possible to support versions of Tomcat >6.

# Instructions
This ODK Aggregate image must be paired with a MySQL container to function
properly. The `docker-compose.yml` configuration covers a basic integration of
these 2 services, but may not be suitable for production. You override any of
the environment variables listed in the Compose files with equivalents defined
on your host.

To create the ODK Aggregate and MySQL containers, run: `docker-compose up -d`
