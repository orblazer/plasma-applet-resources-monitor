#!/usr/bin/env bash
set -e

LAST_TAG=$(git describe --tags --abbrev=0 || echo "v0.0.0")
COMMITS=$(git log "$LAST_TAG"..HEAD --pretty=format:%s)

if [ -z "$COMMITS" ]; then
  echo "No commits since last tag ($LAST_TAG). Nothing to release."
  exit 0
fi

# Determine bump type
BUMP="patch"
if echo "$COMMITS" | grep -q "BREAKING CHANGE"; then
  BUMP="major"
elif echo "$COMMITS" | grep -q "^feat"; then
  BUMP="minor"
fi
echo "Bump type detected: $BUMP"

# Read current version
CURRENT_VERSION=$(jq -r '.KPlugin.Version' package/metadata.json)
IFS='.' read -r MAJOR MINOR PATCH <<< "$CURRENT_VERSION"

# Apply bump
case "$BUMP" in
  major) MAJOR=$((MAJOR + 1)); MINOR=0; PATCH=0 ;;
  minor) MINOR=$((MINOR + 1)); PATCH=0 ;;
  patch) PATCH=$((PATCH + 1)) ;;
esac
NEW_VERSION="$MAJOR.$MINOR.$PATCH"

# Update metadata.json only if needed
if [ "$CURRENT_VERSION" != "$NEW_VERSION" ]; then
  jq ".KPlugin.Version = \"$NEW_VERSION\"" package/metadata.json > package/metadata.tmp.json
  mv package/metadata.tmp.json package/metadata.json
  git add package/metadata.json

  # Commit only if there are changes
  if ! git diff --cached --quiet; then
    git commit -m "chore(release): v$NEW_VERSION 🎉"
  else
    echo "No changes to commit (version already up to date)"
  fi
else
  echo "Version is already $NEW_VERSION, skipping metadata update"
fi

# Create tag only if it doesn't exist
if git rev-parse "v$NEW_VERSION" >/dev/null 2>&1; then
  echo "Tag v$NEW_VERSION already exists, skipping tag creation"
else
  git tag -a "v$NEW_VERSION" -m "Release v$NEW_VERSION"
fi

CURRENT_BRANCH=$(git symbolic-ref --short HEAD)
git push origin "$CURRENT_BRANCH" --tags || true
echo "✅ Release created: v$NEW_VERSION"
