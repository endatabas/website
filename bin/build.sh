#!/usr/bin/env bash

set -x
set -e
(
    cd $(dirname "$0")/../docs/bib/
    bibtex2html bibliography.bib
)
