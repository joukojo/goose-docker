# Goose Docker Image

This repository builds a minimal Docker image for the `goose` database migration tool.
It installs the `goose` CLI in a tiny Debian runtime image and runs it as a non-root user.

## What’s Inside

- `goose` CLI version `v3.26.0`
- Default database driver: `postgres`
- Migrations directory inside the container: `/migrations`
- Runs as user: `goose` (non-root)

## Build

```bash
docker build -t goose-image .
```

## Run

Mount your migrations folder and provide a connection string.

```bash
docker run --rm \
  -v "$(pwd)/migrations:/migrations" \
  -e GOOSE_DBSTRING="postgres://user:pass@host:5432/dbname?sslmode=disable" \
  goose-image \
  up
```

## Docker Compose Example

This example runs migrations against a `postgres` service on the same compose network.
Update the `POSTGRES_*` values and the `GOOSE_DBSTRING` as needed.

```yaml
services:
  db:
    image: postgres:16
    environment:
      POSTGRES_USER: app
      POSTGRES_PASSWORD: secret
      POSTGRES_DB: app
    ports:
      - "5432:5432"

  migrate:
    image: goose-image
    depends_on:
      - db
    environment:
      GOOSE_DRIVER: postgres
      GOOSE_DBSTRING: postgres://app:secret@db:5432/app?sslmode=disable
    volumes:
      - ./migrations:/migrations
    command: ["up"]
```

## Configuration

The image exposes the common `goose` environment variables:

- `GOOSE_DRIVER` (default: `postgres`)
- `GOOSE_DBSTRING` (required: your connection string)
- `GOOSE_MIGRATION_DIR` (default: `/migrations`)
- `GOOSE_TABLE` (default: `public.goose_migrations`)

You can override any of these at runtime:

```bash
docker run --rm \
  -v "$(pwd)/migrations:/migrations" \
  -e GOOSE_DRIVER="postgres" \
  -e GOOSE_DBSTRING="postgres://user:pass@host:5432/dbname?sslmode=disable" \
  -e GOOSE_MIGRATION_DIR="/migrations" \
  -e GOOSE_TABLE="public.goose_migrations" \
  goose-image \
  status
```

## Common Commands

```bash
docker run --rm -v "$(pwd)/migrations:/migrations" -e GOOSE_DBSTRING="..." goose-image up
docker run --rm -v "$(pwd)/migrations:/migrations" -e GOOSE_DBSTRING="..." goose-image down
docker run --rm -v "$(pwd)/migrations:/migrations" -e GOOSE_DBSTRING="..." goose-image status
```

## Notes

- The container entrypoint is `goose`, so any CLI arguments you pass after the image name are forwarded to `goose`.
- If you run migrations against a database that’s also in Docker, ensure both containers share a network.
