#!/bin/bash
PLASMOID_DIR='~/.local/share/plasma/plasmoids/'
PACKAGE_NAME=org.kde.resourcesMonitor-fork

if [ -d "${PLASMOID_DIR}${PACKAGE_NAME}" ]
then
  echo 'Install applet...'
  kpackagetool5 -t Plasma/Applet --install package
else
  echo 'Update applet...'
  kpackagetool5 -t Plasma/Applet --upgrade package
fi

echo 'Restart plasma'
killall plasmashell
kstart5 plasmashell
