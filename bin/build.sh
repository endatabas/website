#!/usr/bin/env bash

#set -x
#set -e
(
    printf "\nGenerating bibliography...\n"
    cd $(dirname "$0")/../src/bib/
    # -q is too quiet, -w doesn't actually stop on warning:
    bibtex2html -a -noabstract -nokeywords bibliography.bib
    perl -p0e 's/.*<table>/<table>/s' bibliography.html > ../../src/partials/_bib_table.html.tmp
    perl -p0e 's/<\/table>.*/<\/table>\n/s' ../../src/partials/_bib_table.html.tmp > ../../src/partials/_bib_table.html
    perl -p0e 's/<title>bibliography.bib<\/title>/<title>bibliography.bib<\/title>\n<link rel="stylesheet" href="\/resources\/css\/dark.css" media="(prefers-color-scheme: dark)" \/>\n<link rel="stylesheet" href="\/resources\/css\/light.css" media="(prefers-color-scheme: light)" \/>\n<link rel="stylesheet" href="\/resources\/css\/bib_bib.css" \/>/g' bibliography_bib.html > ../../src/bibliography_bib.html
)

(
    printf "\nM4 Replacing...\n"
    cd $(dirname "$0")/../
    m4 -I "./src/partials/" src/beta2.html > docs/beta2.html
    m4 -I "./src/partials/" src/bibliography.html > docs/bibliography.html
    m4 -I "./src/partials/" src/bibliography_bib.html > docs/bibliography_bib.html
)
