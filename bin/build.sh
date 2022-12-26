#!/usr/bin/env bash

set -x
set -e
(
    cd $(dirname "$0")/../docs/bib/
    bibtex2html bibliography.bib
    # MacOS uses BSD sed, which requires a param for -i, so...
    sed 's/<title>bibliography<\/title>/<title>bibliography<\/title>\n<link rel="stylesheet" href="\/resources\/css\/dark.css" media="(prefers-color-scheme: dark)" \/>\n<link rel="stylesheet" href="\/resources\/css\/light.css" media="(prefers-color-scheme: light)" \/>\n<link rel="stylesheet" href="\/resources\/css\/bib.css" \/>/g' bibliography.html > bibliography_themed.html
    mv bibliography.html bibliography.html.bak
    mv bibliography_themed.html bibliography.html
)
