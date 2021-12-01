#!/bin/sh
# Version: 7

# This script will convert the *.po files to *.mo files, rebuilding the package/contents/locale folder.
# Feature discussion: https://phabricator.kde.org/D5209
# Eg: contents/locale/fr_CA/LC_MESSAGES/plasma_applet_org.kde.plasma.eventcalendar.mo

packageRoot=$(realpath "$(dirname "${BASH_SOURCE[0]}")/../package") # Root of translatable sources
DIR="$packageRoot/translate"
plasmoidName=`kreadconfig5 --file="$DIR/../metadata.desktop" --group="Desktop Entry" --key="X-KDE-PluginInfo-Name"`
projectName="plasma_applet_${plasmoidName}" # project name

cd $DIR

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
echo "[build] Updating .desktop file"

# Generate LINGUAS for msgfmt
catalogs=`find . -name '*.po' | sort`
if [ -f "$DIR/LINGUAS" ]; then
	rm "$DIR/LINGUAS"
fi
touch "$DIR/LINGUAS"
for cat in $catalogs; do
	catLocale=`basename ${cat%.*}`
	echo "${catLocale}" >> "$DIR/LINGUAS"
done

cp -f "$DIR/../metadata.desktop" "$DIR/template.desktop"
sed -i '/^Name\[/ d; /^GenericName\[/ d; /^Comment\[/ d; /^Keywords\[/ d' "$DIR/template.desktop"

msgfmt \
	--desktop \
	--template="$DIR/template.desktop" \
	-d "$DIR/" \
	-o "$DIR/new.desktop"

# Delete empty msgid messages that used the po header
if [ ! -z "$(grep '^Name=$' "$DIR/new.desktop")" ]; then
	echo "[merge] Name in metadata.desktop is empty!"
	sed -i '/^Name\[/ d' "$DIR/new.desktop"
fi
if [ ! -z "$(grep '^GenericName=$' "$DIR/new.desktop")" ]; then
	echo "[merge] GenericName in metadata.desktop is empty!"
	sed -i '/^GenericName\[/ d' "$DIR/new.desktop"
fi
if [ ! -z "$(grep '^Comment=$' "$DIR/new.desktop")" ]; then
	echo "[merge] Comment in metadata.desktop is empty!"
	sed -i '/^Comment\[/ d' "$DIR/new.desktop"
fi
if [ ! -z "$(grep '^Keywords=$' "$DIR/new.desktop")" ]; then
	echo "[merge] Keywords in metadata.desktop is empty!"
	sed -i '/^Keywords\[/ d' "$DIR/new.desktop"
fi

# Place translations at the bottom of the desktop file.
translatedLines=`cat "$DIR/new.desktop" | grep "]="`
if [ ! -z "${translatedLines}" ]; then
	sed -i '/^Name\[/ d; /^GenericName\[/ d; /^Comment\[/ d; /^Keywords\[/ d' "$DIR/new.desktop"
	if [ "$(tail -c 1 "$DIR/new.desktop" | wc -l)" != "1" ]; then
		# Does not end with 1 empty lines, so add an empty line.
		echo "" >> "$DIR/new.desktop"
	fi
	echo "${translatedLines}" >> "$DIR/new.desktop"
fi

# Cleanup
mv "$DIR/new.desktop" "$DIR/../metadata.desktop"
rm "$DIR/template.desktop"
rm "$DIR/LINGUAS"

#---
echo "[build] Updating translate/README.md"
# Count line in template
potMessageCount=`expr $(grep -Pzo 'msgstr ""\n(\n|$)' "template.pot" | grep -c 'msgstr ""')`
echo "|  Locale  |  Lines  | % Done|" > "./Status.md"
echo "|----------|---------|-------|" >> "./Status.md"
entryFormat="| %-8s | %7s | %5s |"
templateLine=`perl -e "printf(\"$entryFormat\", \"Template\", \"${potMessageCount}\", \"\")"`
echo "$templateLine" >> "./Status.md"

# Count line in translations
for cat in $catalogs; do
	echo "[build] $cat"
	catLocale=`basename ${cat%.*}`

	poEmptyMessageCount=`expr $(grep -Pzo 'msgstr ""\n(\n|$)' "$cat.new" | grep -c 'msgstr ""')`
	poMessagesDoneCount=`expr $potMessageCount - $poEmptyMessageCount`
	poCompletion=`perl -e "printf(\"%d\", $poMessagesDoneCount * 100 / $potMessageCount)"`
	poLine=`perl -e "printf(\"$entryFormat\", \"$catLocale\", \"${poMessagesDoneCount}/${potMessageCount}\", \"${poCompletion}%\")"`
	echo "$poLine" >> "./Status.md"
done

sed -i '/^|/ d' ./README.md # Remove status table from README
cat ./Status.md >> ./README.md
rm ./Status.md
echo "[build] Done updating translate/README.md"

#---
echo "[build] Compiling messages"

catalogs=`find . -name '*.po' | sort`
for cat in $catalogs; do
	echo "$cat"
	catLocale=`basename ${cat%.*}`
	msgfmt -o "${catLocale}.mo" "$cat"

	installPath="$DIR/../contents/locale/${catLocale}/LC_MESSAGES/${projectName}.mo"

	echo "[build] Install to ${installPath}"
	mkdir -p "$(dirname "$installPath")"
	mv "${catLocale}.mo" "${installPath}"
done

echo "[build] Done building messages"
