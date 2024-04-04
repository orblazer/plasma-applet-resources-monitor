#!/bin/bash
# Version: 7

# This script will convert the *.po files to *.mo files, rebuilding the package/contents/locale folder.
# Feature discussion: https://phabricator.kde.org/D5209
# Eg: contents/locale/fr_CA/LC_MESSAGES/plasma_applet_org.kde.plasma.eventcalendar.mo

packageRoot=$(realpath "$(dirname "${BASH_SOURCE[0]}")/../package") # Root of translatable sources
DIR="$packageRoot/translate"
plasmoidName="org.kde.plasma.resources-monitor"
projectName="plasma_applet_${plasmoidName}" # project name

cd "$DIR" || return

#---
if [ -z "$plasmoidName" ]; then
	echo "[build] Error: Couldn't read plasmoidName."
	exit
fi

if [ -z "$(which msgfmt)" ]; then
	echo "[build] Error: msgfmt command not found. Need to install gettext"
	echo "[build] Running 'sudo apt install gettext'"
	sudo apt install gettext
	echo "[build] gettext installation should be finished. Going back to installing translations."
fi

#---
echo "[build] Compiling messages"

catalogs=$(find . -name '*.po' | sort)
for cat in $catalogs; do
	echo "$cat"
	catLocale=$(basename "${cat%.*}")
	msgfmt -o "${catLocale}.mo" "$cat"

	installPath="$DIR/../contents/locale/${catLocale}/LC_MESSAGES/${projectName}.mo"

	echo "[build] Install to ${installPath}"
	mkdir -p "$(dirname "$installPath")"
	mv "${catLocale}.mo" "${installPath}"
done

echo "[build] Done building messages"
