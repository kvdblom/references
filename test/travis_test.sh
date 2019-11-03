#!/bin/bash
set -u
set -o pipefail

travis_fold_start() {
  echo -e "travis_fold:start:$1\033[33;1m$2\033[0m"
}

travis_fold_end() {
  echo -e "\ntravis_fold:end:$1\r"
}
grep --quiet -e "doi[[:space:]]*=.\+http" ../*.bib
if [ $? -eq 0 ]; then
    echo "Error: the doi field should not be an URL"
    grep -n -e "doi[[:space:]]*=.\+http" ../*.bib
    exit 1
fi

travis_fold_start

latexmk -halt-on-error -interaction=nonstopmode -gg --pdf testbib.tex | tee .bibtex-warnings

travis_fold_end

if [ $? -ne 0 ]; then
    echo "Error: latexmk failed"
    exit 1
fi

grep --quiet "Warning--" .bibtex-warnings
if [ $? -eq 0 ]; then
    echo "Error: Please fix bibtex Warnings:"
    grep "Warning--" .bibtex-warnings
    exit 1
fi
echo "No bibtex warnings! Good job!"

exit 0
