#!/usr/bin/env bash

#set -x
#set -e
(
    strip_table () {
        perl -p0e 's/.*<table>/<table>/s' $1 > ../../src/partials/$2.tmp
        perl -p0e 's/<\/table>.*/<\/table>\n/s' ../../src/partials/$2.tmp > ../../src/partials/$2
    }

    style_bib_bib () {
        TITLE="<title>$1.bib<\/title>"
        DARK_CSS='<link rel="stylesheet" href="\/resources\/css\/dark.css" media="(prefers-color-scheme: dark)" \/>'
        LIGHT_CSS='<link rel="stylesheet" href="\/resources\/css\/light.css" media="(prefers-color-scheme: light)" \/>'
        BIBBIB_CSS='<link rel="stylesheet" href="\/resources\/css\/bib_bib.css" \/>'
        perl -p0e "s/$TITLE/$TITLE\n$DARK_CSS\n$LIGHT_CSS\n$BIBBIB_CSS/g" $1_bib.html > ../../src/$1_bib.html
    }

    cd $(dirname "$0")/../src/bib/

    printf "\n#### Bib2bib combining references + research...\n"
    bib2bib -ob bibliography.bib references.bib research.bib

    printf "\n#### Generating references...\n"
    # -q is too quiet, -w doesn't actually stop on warning:
    bibtex2html -a -noabstract -nokeywords references.bib
    strip_table "references.html" "_ref_table.html"
    style_bib_bib "references"

    printf "\n#### Generating bibliography...\n"
    bibtex2html -a -noabstract -nokeywords bibliography.bib
    strip_table "bibliography.html" "_bib_table.html"
    style_bib_bib "bibliography"
)

(
    printf "\n#### M4 macros...\n"
    cd $(dirname "$0")/../
    m4 -I "./src/partials/" src/index.html > docs/index.html
    m4 -I "./src/partials/" src/references.html > docs/references.html
    m4 -I "./src/partials/" src/references_bib.html > docs/references_bib.html
    m4 -I "./src/partials/" src/bibliography.html > docs/bibliography.html
    m4 -I "./src/partials/" src/bibliography_bib.html > docs/bibliography_bib.html
    m4 -I "./src/partials/" src/demo.html > docs/demo.html
)

printf "#### ...done.\n"
