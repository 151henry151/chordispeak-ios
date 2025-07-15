#!/usr/bin/env bash
# bump_version.sh: Bump the version in the VERSION file (major, minor, or patch)
# Usage: ./bump_version.sh [major|minor|patch]

set -e

if [ ! -f VERSION ]; then
  echo "VERSION file not found!" >&2
  exit 1
fi

BUMP_TYPE=${1:-patch}

VERSION=$(cat VERSION)
IFS='.' read -r MAJOR MINOR PATCH <<< "$VERSION"

case $BUMP_TYPE in
  major)
    MAJOR=$((MAJOR + 1))
    MINOR=0
    PATCH=0
    ;;
  minor)
    MINOR=$((MINOR + 1))
    PATCH=0
    ;;
  patch)
    PATCH=$((PATCH + 1))
    ;;
  *)
    echo "Usage: $0 [major|minor|patch]" >&2
    exit 1
    ;;
esac

NEW_VERSION="$MAJOR.$MINOR.$PATCH"
echo "$NEW_VERSION" > VERSION
echo "Bumped version to $NEW_VERSION" 