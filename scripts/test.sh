#!/bin/bash
# Enable debug for Fedora
if (cat /etc/*release | grep ^NAME | grep -q Fedora) || [ "${DEBUG^^}" == "TRUE" ]
then
  export QT_LOGGING_RULES="*.debug=true; qt.*.debug=false"
fi

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
