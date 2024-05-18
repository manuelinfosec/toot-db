#!/usr/bin/env bash

set -euo pipefail

cargo build --release --bin tootdb

for ID in a b c d e; do
    (cargo run -q --release -- -c tootdb-$ID/tootdb.yaml 2>&1 | sed -e "s/\\(.*\\)/tootdb-$ID \\1/g") &
done

trap 'kill $(jobs -p)' EXIT
wait < <(jobs -p)