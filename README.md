# Football Results

> API for football results

## Development

This project uses protocol buffers. The files are located under `lib/proto/*.proto`.
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

TODO: Add instructions

## Tasks

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
