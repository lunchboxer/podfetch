#!/bin/sh

# copy to $CONFIG_DIR/scripts to use

DOWNLOAD_DIR="$HOME/Downloads/podcasts"

# pipe separated list
AFFECTED_PODCASTS="NPR News Now"
FILES_TO_KEEP=1

for PODCAST in $AFFECTED_PODCASTS; do
  find "$DOWNLOAD_DIR" -type f -name "$PODCAST*" -exec stat -c '%W|%n' {} \; |
    sort |
    head -n -$FILES_TO_KEEP |
    cut -d'|' -f2 |
    xargs -r -I {} rm "{}"
done
