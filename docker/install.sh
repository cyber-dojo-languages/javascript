#!/bin/bash -Eeu

npm install --global jshint

# Records the JavaScript this image holds, in the shape every image shares.
# Its version is node's, the runtime a kata runs on. The installed node is
# asked, so the version is one the image can run rather than one written down
# when someone last edited this file. node -v prints "v26.8.2".
readonly LANGUAGE_VERSION=$(node -v | cut -c2-)

if [ -z "${LANGUAGE_VERSION}" ]; then
  echo 'Could not read a version from node -v' >&2
  exit 1
fi

cat > /versions.json <<EOF
{
  "language": {
    "name": "JavaScript",
    "version": "${LANGUAGE_VERSION}"
  },
  "test_frameworks": []
}
EOF
