#!/usr/bin/env bash
set -e

VERSION=$(jq -r '.KPlugin.Version' package/metadata.json)
OUTPUT="resources-monitor-${VERSION}.plasmoid"

echo "🔹 Building translations..."
./scripts/translate-build.sh

# Remove existing package if it exists
[ -f "$OUTPUT" ] && rm "$OUTPUT"
echo "🔹 Creating .plasmoid package..."
cd package
zip -q -r -9 "../$OUTPUT" . -x "translate/*"
cd ..

echo "📦 Package created: $OUTPUT"
