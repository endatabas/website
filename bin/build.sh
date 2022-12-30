#!/usr/bin/env bash

#set -x
#set -e

HEADER=`cat $(dirname "$0")/../docs/partials/_header.html`
HEADER_FILE=`realpath $(dirname "$0")/../docs/partials/_header.html`

(
    printf "\nGenerating bibliography...\n"
    cd $(dirname "$0")/../docs/bib/
    bibtex2html bibliography.bib
    # MacOS uses BSD sed, which requires a param for -i, so...
    sed 's/<title>bibliography<\/title>/<title>bibliography<\/title>\n<link rel="stylesheet" href="\/resources\/css\/dark.css" media="(prefers-color-scheme: dark)" \/>\n<link rel="stylesheet" href="\/resources\/css\/light.css" media="(prefers-color-scheme: light)" \/>\n<link rel="stylesheet" href="\/resources\/css\/beta2.css" \/>\n<link rel="stylesheet" href="\/resources\/css\/bib.css" \/>/g' bibliography.html > bibliography_themed.html
    mv bibliography.html bibliography.html.bak
    mv bibliography_themed.html bibliography.html
)

printf "\nReplacing bib tokens...\n"
(
    # "s/<body>/<body color-mode=\"user\">$HEADER/g"
    cd $(dirname "$0")/../docs/bib/
    echo $HEADER_FILE
    sed "/<body>/{
        s/<body>/<body color-mode=\"user\">/g
        r $HEADER_FILE
    }" bibliography.html > bibliography_tokenized.html
    mv bibliography.html bibliography.html.bak2
    mv bibliography_tokenized.html bibliography.html
)
