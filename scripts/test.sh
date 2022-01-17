#!/bin/bash
# Enable debug for Fedora
if ! [ -z "$(cat /etc/*release | grep ^NAME | grep Fedora)" ] || [ "${DEBUG^^}" == "TRUE" ]
then
  export QT_LOGGING_RULES="*.debug=true; qt.*.debug=false"
fi

echo 'Run applet...'
plasmoidviewer -a $(pwd)/package
