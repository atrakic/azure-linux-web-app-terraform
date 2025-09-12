#!/usr/bin/env bash

set -eo pipefail

URI=${URI:-http://localhost:8000}

declare -a opts
opts=(
  -fiskL
  -H 'Accept: application/json'
)

[ -n "$API_TOKEN" ] && opts+=( -H "Authorization: Bearer '$API_TOKEN'" )

## REST
curl "${opts[@]}" "${URI}" #| jq -r "."
