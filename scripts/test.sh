#!/bin/bash
export QT_LOGGING_RULES="qml.debug=true"

lang=$LANG
language=$LANGUAGE
if [ -n "$1" ]; then
  if [[ "$1" == *"_"* ]]; then
    mapfile -t parts < <(echo "$1" | tr '_' '\n')

    lang="${1}.UTF-8"
    language="${1}:${parts[0]}"
  else
    lang="${1}_${1^^}.UTF-8"
    language="${1}_${1^^}:${1}"
  fi
fi

echo 'Run applet...'
LANGUAGE=$language LANG=$lang plasmoidviewer -a "$(pwd)/package"
