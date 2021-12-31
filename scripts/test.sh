#!/bin/bash
PLASMOID_DIR='~/.local/share/plasma/plasmoids/'
PACKAGE_NAME=org.kde.resourcesMonitor-fork

# Enable debug for Fedora
if ! [ -z "$(cat /etc/*release | grep ^NAME | grep Fedora)" ]
then
  export QT_LOGGING_RULES="*.debug=true; qt.*.debug=false"
fi

if [ -d "${PLASMOID_DIR}${PACKAGE_NAME}" ]
then
  echo 'Install applet...'
  kpackagetool5 -t Plasma/Applet --install package
else
  echo 'Update applet...'
  kpackagetool5 -t Plasma/Applet --upgrade package
fi

echo 'Run applet...'
if ! [ -x "$(command -v plasmoidviewer)" ]
then
  plasmawindowed $PACKAGE_NAME
else
  plasmoidviewer -a $PACKAGE_NAME
fi
