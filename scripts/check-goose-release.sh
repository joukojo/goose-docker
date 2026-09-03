#!/usr/bin/env bash

set -euo pipefail

readonly UPSTREAM_LATEST_URL="https://github.com/pressly/goose/releases/latest"
readonly SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly REPOSITORY_DIR="$(cd -- "${SCRIPT_DIR}/.." && pwd)"
readonly DOCKERFILE="${REPOSITORY_DIR}/Dockerfile"

if ! command -v curl >/dev/null 2>&1; then
  echo "Error: curl is required." >&2
  exit 2
fi

if [[ ! -r "${DOCKERFILE}" ]]; then
  echo "Error: cannot read ${DOCKERFILE}." >&2
  exit 2
fi

current_version="$(
  sed -nE \
    's|.*github\.com/pressly/goose/v3/cmd/goose@(v[0-9]+\.[0-9]+\.[0-9]+).*|\1|p' \
    "${DOCKERFILE}" | head -n 1
)"

if [[ -z "${current_version}" ]]; then
  echo "Error: could not find the pinned Goose version in ${DOCKERFILE}." >&2
  exit 2
fi

latest_release_url="$(
  curl --fail --silent --show-error --location \
    --output /dev/null --write-out '%{url_effective}' \
    "${UPSTREAM_LATEST_URL}"
)"
latest_version="${latest_release_url##*/}"

if [[ ! "${latest_version}" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "Error: GitHub returned an unexpected release tag: ${latest_version}" >&2
  exit 2
fi

if [[ "${current_version}" == "${latest_version}" ]]; then
  echo "Goose is up to date: ${current_version}"
  exit 0
fi

echo "A new Goose release is available: ${current_version} -> ${latest_version}"
echo "Release: https://github.com/pressly/goose/releases/tag/${latest_version}"
exit 1
