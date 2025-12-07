#!/bin/sh

# Download podcast fees
# check the feeds for new episodes
# download new episodes

CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/podfetch"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/podfetch"
FEEDS_DIR="$CACHE_DIR/feeds"
DOWNLOADED_LOG="$CACHE_DIR/downloaded.log"
PENDING_LIST="$CACHE_DIR/pending.list"
DOWNLOAD_DIR="$HOME/Downloads/podcasts"
FEED_URL_LIST="$CONFIG_DIR/feed-url-list.txt"

# 1 Download all the feeds listed in the config file
mkdir -p "$CONFIG_DIR" "$CACHE_DIR/feeds" "$DOWNLOAD_DIR"

echo "Fetching podcast feeds..."
feednum=0
while IFS= read -r line || [ -n "$line" ]; do
  # Allow for comments in the config file
  url=${line%%#*}
  url=$(echo "$url" | xargs)

  [ -z "$url" ] && continue
  feednum=$((feednum + 1))

  echo "  $feednum: $url"

  FILENAME=$(echo "$url" | md5sum | cut -d ' ' -f 1)
  curl -s -L "$url" -o "$CACHE_DIR/feeds/$FILENAME.xml"
done <"$FEED_URL_LIST"

# 2 Check for new episodes to download
mkdir -p "$FEEDS_DIR"
touch "$DOWNLOADED_LOG"
truncate -s 0 "$PENDING_LIST"

echo "Checking for new episodes..."
for FEED_FILE in "$FEEDS_DIR"/*; do
  [ -f "$FEED_FILE" ] || continue

  PODCAST_NAME=$(xmlstarlet sel -t -m "//channel" -v "title" -n "$FEED_FILE")
  EPISODE_TITLE=$(xmlstarlet sel -t -m "//item[1]" -v "title" -n "$FEED_FILE")
  DOWNLOAD_URL=$(xmlstarlet sel -t -m "//item[1]" -v "enclosure/@url" -n "$FEED_FILE")

  if grep -qF "$DOWNLOAD_URL" "$DOWNLOADED_LOG"; then
    echo "  [SKIP] '$EPISODE_TITLE' has already been downloaded."
  else
    echo "  [NEW] $PODCAST_NAME - '$EPISODE_TITLE' is available."
    METADATA=$(printf "%s|%s|%s" "$PODCAST_NAME" "$EPISODE_TITLE" "$DOWNLOAD_URL")
    echo "$METADATA" >>"$PENDING_LIST"
  fi

done

# 3 Download the new episodes
if [ ! -s "$PENDING_LIST" ]; then
  exit 0
fi

echo "Downloading new episodes..."

while IFS="|" read -r PODCAST TITLE URL; do
  EPISODE_SLUG=$(echo "$TITLE" | sed -e 's/[^a-zA-Z0-9]//g' -e 's/^-//g' -e 's/-$//g' | cut -c -30)
  FINAL_PATH="$DOWNLOAD_DIR/$PODCAST - $EPISODE_SLUG.mp3"
  if wget -q -c --show-progress --progress=bar:force:noscroll "$URL" -O "$FINAL_PATH"; then
    echo "$URL" >>"$DOWNLOADED_LOG"
  fi
done <"$PENDING_LIST"

rm "$PENDING_LIST"

echo "Downloads complete."

# 4 Run userscripts in $CONFIG_DIR/scripts in alphanumeric order

echo "Running scripts..."
for SCRIPT in "$CONFIG_DIR/scripts"/*; do
  [ -f "$SCRIPT" ] || continue
  echo "  script: $SCRIPT"
  "$SCRIPT"
done

