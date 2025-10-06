#!/bin/bash
# Usage: ./epub2m4b.sh "My Book.epub" "Cover.jpg" "Author Name"
# Example: ./epub2m4b.sh "VETERAN BENEFITS SECRETS UNLOCKED.epub" "cover.jpg" "Jesse Roper"

EPUB="$1"
COVER="$2"
AUTHOR="$3"

if [ -z "$EPUB" ]; then
    echo "Usage: $0 <EPUB file> [cover.jpg] [Author Name]"
    exit 1
fi

BASENAME=$(basename "$EPUB" .epub)
TXT="/tmp/${BASENAME}.txt"
AIFF="/tmp/${BASENAME}.aiff"
M4A="/tmp/${BASENAME}.m4a"
M4B="${BASENAME}.m4b"
TMP_M4B="/tmp/${BASENAME}_tagged.m4b"

# 1️⃣ Convert EPUB → plain text
pandoc "$EPUB" -t plain -o "$TXT"

# 2️⃣ Convert text → raw AIFF audio using macOS TTS
say -v "Alex" -r 150 -f "$TXT" -o "$AIFF"

# 3️⃣ Convert AIFF → AAC .m4a
ffmpeg -y -i "$AIFF" -c:a aac -b:a 128k "$M4A"

# 4️⃣ Convert .m4a → .m4b with metadata and optional cover
if [ -f "$COVER" ]; then
    ffmpeg -y -i "$M4A" -i "$COVER" \
        -map 0:a -map 1 \
        -c:a copy -c:v copy \
        -metadata title="$BASENAME" \
        -metadata artist="$AUTHOR" \
        -metadata album="$BASENAME" \
        -metadata genre="Audiobook" \
        -disposition:v:0 attached_pic \
        "$TMP_M4B"
else
    ffmpeg -y -i "$M4A" \
        -c:a copy \
        -metadata title="$BASENAME" \
        -metadata artist="$AUTHOR" \
        -metadata album="$BASENAME" \
        -metadata genre="Audiobook" \
        "$TMP_M4B"
fi

# 5️⃣ Clean up intermediate files
rm "$TXT" "$AIFF" "$M4A"

# 6️⃣ Move final M4B to current directory
mv "$TMP_M4B" "$M4B"

echo "✅ Audiobook created: $M4B"



