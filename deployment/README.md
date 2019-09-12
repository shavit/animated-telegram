# Deployment

Create a release with mix
```
$ mix release
```

You can then use the binary to upgrade a running app, connect
  or create a new one.

To view all the options:
```
$ ./_build/prod/rel/football_results/bin/football_results
```

## Distillery

The project uses `distillery` to create releases.
```
$ mix distillery.release --verbose
```

Read more on the [distillery GitHub page](https://github.com/bitwalker/distillery)

## Docker

The Dockerfile installs dependencies, create a release with *distillery*, and then
  use the release image to copy the tarball into `/srv/app`.

It is important to include `./res/data.csv` in the project root. The file and
 the `res` directory are not part of the project.

You can also override the path to `data.csv` in the Docker file, and pass `CSV_FILEPATH`
  as a build argument. Edit the Dockerfile only if you want to change the file path:
```
# deployment/Dockerfile

#ARG CSV_FILEPATH="res/data.csv"
#COPY ${CSV_FILEPATH} data.csv
#ENV CSV_FILEPATH=data.csv
```

Then replace this line
```
# deployment/Dockerfile

COPY ${PWD}/ .
COPY ${CSV_FILEPATH} srv/data.csv
```

## Kubernetes

To deploy or update a cluster:
```
$ kubectl apply -f kubernetes/kubernetes-production.yml
```

You will need to install [kubectl command tool](https://kubernetes.io/docs/tasks/tools/install-kubectl/),
 and [set its credentials](https://kubernetes.io/docs/reference/access-authn-authz/authentication/).

the `deployment/kubernetes-production.yml` file.

## Docker Compose

If you choose to use the `docker-compose.yml` file at `deployment/docker-compose.yml`,
  then it does not expose the service's ports, and it only accessed through *HAProxy*.

With *HAProxy*, the public gRPC port is `4002`.

  * Read more about [Docker Compose](https://docs.docker.com/compose/)
  * [Docker Compose file reference](https://docs.docker.com/compose/compose-file/)
  * Read more about [HAProxy](https://cbonte.github.io/haproxy-dconv/1.7/configuration.html#2.3).

Build and start the service:
```
$ docker-compose -f deployment/docker-compose.yml up
```