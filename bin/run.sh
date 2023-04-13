#!/usr/bin/env bash

(
  cd $(dirname "$0")/../docs/
  python3 -m http.server 8000
)

