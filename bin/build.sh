#!/usr/bin/env bash

#set -x
#set -e
(
    strip_table () {
        perl -p0e 's/.*<table>/<table>/s' $1 > ../../src/partials/$2.tmp
        perl -p0e 's/<\/table>.*/<\/table>\n/s' ../../src/partials/$2.tmp > ../../src/partials/$2
    }

    style_bib_bib () {
        perl -p0e "s/<title>$1.bib<\/title>/<title>$1.bib<\/title>\n<link rel=\"stylesheet\" href=\"\/resources\/css\/dark.css\" media=\"(prefers-color-scheme: dark)\" \/>\n<link rel=\"stylesheet\" href=\"\/resources\/css\/light.css\" media=\"(prefers-color-scheme: light)\" \/>\n<link rel=\"stylesheet\" href=\"\/resources\/css\/bib_bib.css\" \/>/g" $1_bib.html > ../../src/$1_bib.html
    }

    printf "\nGenerating bibliography...\n"
    cd $(dirname "$0")/../src/bib/
    bib2bib -ob bibliography.bib references.bib research.bib
    # -q is too quiet, -w doesn't actually stop on warning:
    bibtex2html -a -noabstract -nokeywords references.bib
    strip_table "references.html" "_ref_table.html"
    style_bib_bib "references"

    bibtex2html -a -noabstract -nokeywords bibliography.bib
    strip_table "bibliography.html" "_bib_table.html"
    style_bib_bib "bibliography"
)

(
    printf "\nM4 Replacing...\n"
    cd $(dirname "$0")/../
    m4 -I "./src/partials/" src/beta2.html > docs/beta2.html
    m4 -I "./src/partials/" src/references.html > docs/references.html
    m4 -I "./src/partials/" src/references_bib.html > docs/references_bib.html
    m4 -I "./src/partials/" src/bibliography.html > docs/bibliography.html
    m4 -I "./src/partials/" src/bibliography_bib.html > docs/bibliography_bib.html
)
