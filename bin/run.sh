#!/usr/bin/env bash

(
  cd $(dirname "$0")/../docs/
  python -m http.server 8000
)

