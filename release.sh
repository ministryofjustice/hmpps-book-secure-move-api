#!/bin/bash
git stash
git fetch
git checkout origin/main
# Get the latest tag, so we know what the next one will be
currentVersion=$(git describe --abbrev=0)

DATE=$(date "+%Y-%m-%d")
# Replace vx.x.x with the next version
read -p "Enter next version number (current: ${currentVersion}): " NEXT_VERSION
if [ ${NEXT_VERSION:0:1} != 'v' ]
  then
  NEXT_VERSION="v${NEXT_VERSION}"
fi
echo
echo
echo "=========="
echo
echo "Tagging version ${NEXT_VERSION} with message \"Deploying on ${DATE}\""
echo
read -p "Press enter to continue... (Ctrl+C to cancel)" go

git tag -a ${NEXT_VERSION} -m "Deploying on ${DATE}"
git push origin $NEXT_VERSION

read -p Generate changelog? Enter to contine or Ctrl+C to quit

git checkout -b changelog-$NEXT_VERSION
bundle
rake changelog
git add CHANGELOG.md
git commit -m "Generated changelog for $NEXT_VERSION"
git push --set-upstream origin changelog-$NEXT_VERSION