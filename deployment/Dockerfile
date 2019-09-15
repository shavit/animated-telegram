FROM elixir:1.9.1-alpine as builder

# In case you want to override the environment
ARG MIX_ENV=prod

# Uncomment these lines if you prefer to load the csv
#  data from different location during runtime or build
# Be aware that the release must include this path
#ARG CSV_FILEPATH="res/data.csv"
#COPY ${CSV_FILEPATH} data.csv

COPY ${PWD}/ .

RUN apk update && apk upgrade --no-cache \
	&& apk add git \
	&& mix do local.hex --force, local.rebar --force \
	&& mix do deps.get, compile --force, distillery.release --verbose \
	&& mkdir -p /srv/app/ \
	&& find _build/ -iname football_results.tar.gz -exec cp {} /srv/app/ \; \
	&& tar -xf /srv/app/football_results.tar.gz -C /srv/app/


# Match the Linux distribution
FROM elixir:1.9.1-alpine

WORKDIR /srv/app
COPY --from=builder /srv/app .
COPY --from=builder /priv /srv/app/priv

RUN apk update && apk upgrade --no-cache \
	&& apk add \
	bash \
	ca-certificates \
	openssl \
	&& adduser -s /bin/sh -u 1001 -G root -h /srv/app -S -D default \
	&& chown -R 1001:0 /srv/app

# Comment these lines if you would like to debug the image
ENTRYPOINT ["/srv/app/bin/football_results"]
CMD ["foreground"]
