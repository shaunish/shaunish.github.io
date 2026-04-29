#!/bin/bash

# exit immediately if any command fails
set -e

# check that a commit message was provided
if [ -z "$1" ]; then
    echo "Error: please provide a commit message"
    echo "Usage: ./deploy.sh 'your commit message'"
    exit 1
fi

COMMIT_MESSAGE="$1"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
EVIDENCE_DIR="$SCRIPT_DIR/olist_evidence"
OUTPUT_DIR="$SCRIPT_DIR/olist"

echo "→ Running sources..."
cd "$EVIDENCE_DIR"
npm run sources

echo "→ Building Evidence..."
npm run build

echo "→ Copying build to Jekyll site..."
rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"
cp -r "$EVIDENCE_DIR/build/." "$OUTPUT_DIR/"
# touch "$OUTPUT_DIR/.nojekyll"

echo "→ Committing and pushing..."
cd "$SCRIPT_DIR"
git add .
git commit -m "$COMMIT_MESSAGE"
git push

echo "✓ Done! Site will be live in a minute or two."