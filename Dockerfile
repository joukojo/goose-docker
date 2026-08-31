FROM golang:1.27.0-trixie AS build

ENV CGO_ENABLED=0 GOBIN=/out
RUN go install github.com/pressly/goose/v3/cmd/goose@v3.27.3




FROM debian:trixie-slim

RUN apt-get update \
  && apt-get install -y --no-install-recommends adduser ca-certificates \
  && rm -rf /var/lib/apt/lists/*

RUN adduser --disabled-password --gecos "" goose \
  && install -d -o goose -g goose /migrations

COPY --from=build /out/goose /usr/local/bin/goose

USER goose

ENV GOOSE_DRIVER=postgres
ENV GOOSE_DBSTRING="SetConnectionStringViaEnv"

ENV GOOSE_MIGRATION_DIR=/migrations
ENV GOOSE_TABLE=public.goose_migrations

ENTRYPOINT  ["/usr/local/bin/goose"]
CMD ["-h"] 
