# Setup

# Deploy
This ODK Aggregate image must be paired with a MySQL container to function properly. The `deploy.sh` script provides a baseline for deployment of the ODK Aggregate server and its paired MySQL container, but further customization may be necessary.

By default, the `deploy.sh` script will mount a volume from the MySQL container to the host machine at `~/data`. Set the `ODK_DB_HOST_PATH` environment variable on the host to change the storage destination of this volume on the host machine.

Certain environment variables are required with `docker run` or `deploy.sh`. These may either be set in the host environment, or provided directly to Docker (with -e, –env, or –env-file).

## MySQL environment variables
The MySQL Docker [repository](https://hub.docker.com/_/mysql/) covers these environment variables in more detail. The ODK Aggregate web app requires that a database be available prior to launch, so certain variables optional in a default MySQL container (e.g., MYSQL_DATABASE) are required here.
* MYSQL_ROOT_PASSWORD
* MYSQL_USER
* MYSQL_PASSWORD
* MYSQL_DATABASE

## ODK Aggregate environment variables
* ODK_HOSTNAME
* ODK_ADMIN_USER (optional)
* ODK_ADMIN_USERNAME (default password = "aggregate")
* ODK_AUTH_REALM (optional, default=ODK Aggregate)
* AGGREGATE_CONTAINER_NAME (optional, default=aggregate)
* DB_CONTAINER_NAME (optional, default=odkdb)
