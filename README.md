# Football Results

> API for football results

This app serves football results from its GraphQL and gRPC APIs.

Features:
1. List the results of football games from different seasons.
2. Filter the results to get a specific division and season.
3. List the different teams, view their overall wins and loses.

## Requirements

1. Elixir 1.9
1. Docker

Make sure you have **Elixir 1.9** installed on your machine. Instructions are
  available [on the official website](https://elixir-lang.org/install.html)
```
$ elixir -v

Erlang/OTP 22 [erts-10.4.4] [source] [64-bit] [smp:4:4] [ds:4:4:10] [async-threads:1] [hipe] [dtrace]

Elixir 1.9.1 (compiled with Erlang/OTP 22)
```

You will also need to install the **Docker Engine**. Instructions are available
  [on the official website](https://docs.docker.com/install/)
```
$ docker -v

Docker version 18.09.2
```
```
$ docker-compose -v

docker-compose version 1.23.2
```

## Development

Install the dependencies:
```
$ mix deps.get
```

Then start the server with one of these commands:
```
$ iex -S mix
$ mix run --no-halt
```

### HTTP Proxy Server

The public HTTP server and load balancer is HAProxy. You do not need to
  run it for development, except for its configuration.

It will resolve addresses and bypass Docker. If you would like to run it
  without Docker, you will need to edit the hostnames of the services
  in the `deployment/haproxy.cfg` file. A public or private domain name
  as a container name will do.

There is a docker-compose file that you can use to start the proxy and
  app server. It will balance the traffic across 3 services, and it is
  a good idea to start 4 services with one for backup, for higher
  availability.

```
$ docker-compose -f deployment/docker-compose.yml build
$ docker-compose -f deployment/docker-compose.yml up --scale api_server=4
```

![HAProxy demo](https://github.com/shavit/animated-telegram/blob/master/doc/haproxy.gif)


### App Server

The app server uses Cowboy to serve HTTP requests, and it is being used
by Plug to connect between requests and modules in app.

In simple words, the router is configured in `lib/football_results/plug.ex`,
  and the other files under `lib/football_results/plug/` are middleware.

Before you start, make sure you have this file `res/data.csv`.

#### GraphQL

Absinthe is the library that implemented GraphQL. The schema is
  generated from the file `lib/football_results/schema.ex`.

Read more about [Absinthe on Github](https://github.com/absinthe-graphql/absinthe)

#### GraphiQL

There is also a web interface to consume data from the GraphQL API, to read
  documentation about the different types, and export queries.

It is available on `/graphiql`.

Read more about [GraphiQL on Github](https://github.com/graphql/graphiql)

### gRPC

This project also uses protocol buffers to consume the API. The files
  are located under `lib/proto/*.proto`.

To generate the `pb.ex` files run:
```
protoc --elixir_out=plugins=grpc:. ./lib/proto/*.proto
```

To learn about how to install install `protoc` and its plugins, go to the
  [Github page of the project](https://github.com/protocolbuffers/protobuf).
The documentation can be find on [Google Developers](https://developers.google.com/protocol-buffers/).

## Test

Before you use the app, make sure to test it. Ideally it will be deployed
  through a pipeline that include sanity and integration tests.

Run tests using mix
```
mix test --cover
```

## Deployment

This app can run with and without a Docker container. The only external
dependency is its `data.csv` file, that need to be loaded from the file system.

[Read more](deployment)

## Tasks

A `ftbl` is a helper to parse the `data.csv` file with the football results.

Use the help to find the available commands
```
mix help ftbl.load
```

Load the data from a csv file or URL
```
mix ftbl.load path file_path.csv
mix ftbl.load url https://example.com/data.csv
```

A callback need to be implemented to send to results to the database. However,
  the app already use this function to load the file.
