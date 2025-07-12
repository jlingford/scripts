#!/usr/bin/env bash

# USAGE:
# jupynote.sh [TITLE]

# DESCRIPTION: quickly create .qmd notebook for jupyter lab like work

# take first command line argument
TITLE=$1

# set filename
FILENAME="${TITLE:-Untitled}-$(date -u +%Y%m%d).ipynb"

# create new file
touch "${FILENAME}"

echo "{
  \"cells\": [
   {
    \"cell_type\": \"markdown\",
    \"metadata\": {},
    \"source\": [
      \"\"
    ]
   }
  ],
  \"metadata\": {
   \"kernelspec\": {
    \"display_name\": \"Python 3\",
    \"language\": \"python\",
    \"name\": \"python3\"
   },
   \"language_info\": {
    \"codemirror_mode\": {
      \"name\": \"ipython\"
    },
    \"file_extension\": \".py\",
    \"mimetype\": \"text/x-python\",
    \"name\": \"python\",
    \"nbconvert_exporter\": \"python\",
    \"pygments_lexer\": \"ipython3\"
   }
  },
  \"nbformat\": 4,
  \"nbformat_minor\": 5
}" >>${FILENAME}
