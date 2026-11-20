#!/bin/sh
# Builds the live website in docs/ (served by GitHub Pages) from index.html.
# index.html is written for the Claude artifact, which adds <html>, <head> and <body> itself,
# so this script wraps it in a full page and copies the images next to it.
set -e
cd "$(dirname "$0")"

SITE_URL="https://sabekloay2020-ops.github.io/regina-styling/"
OUT=docs
MARK='<div class="backdrop"'   # first line of the page body in index.html

rm -rf "$OUT"
mkdir -p "$OUT/assets"
cp assets/regina-room.jpg assets/regina-logo-ink.png assets/regina-logo-cream.png \
   assets/og-image.jpg assets/favicon.png "$OUT/assets/"

{
cat <<HEAD
<!doctype html>
<html lang="he" dir="rtl">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">
<meta name="description" content="25 שאלות קצרות שעוזרות להכיר את הסגנון שלכם. בסוף שולחים את התשובות בוואטסאפ.">
<meta property="og:type" content="website">
<meta property="og:site_name" content="Regina · Styling with depth">
<meta property="og:title" content="שאלון סטיילינג אישי · Regina">
<meta property="og:description" content="25 שאלות קצרות שעוזרות להכיר את הסגנון שלכם. בסוף שולחים את התשובות בוואטסאפ.">
<meta property="og:image" content="${SITE_URL}assets/og-image.jpg">
<meta property="og:image:width" content="1200">
<meta property="og:image:height" content="630">
<meta property="og:url" content="${SITE_URL}">
<meta name="twitter:card" content="summary_large_image">
<link rel="icon" type="image/png" href="assets/favicon.png">
<link rel="apple-touch-icon" href="assets/favicon.png">
<style>:root{color-scheme:light;padding-top:env(safe-area-inset-top,0px);padding-bottom:env(safe-area-inset-bottom,0px)}body{margin:0;font:14px/1.4 system-ui,sans-serif}img{max-width:100%}[hidden]{display:none!important}</style>
HEAD
grep -q "^$MARK" index.html || { echo "build.sh: could not find the start of the page body in index.html" >&2; exit 1; }
awk -v m="$MARK" 'index($0, m) == 1 { exit } !/claude:viewport-fit-sides/' index.html
echo '</head>'
echo '<body>'
awk -v m="$MARK" 'index($0, m) == 1 { f = 1 } f' index.html
echo '</body>'
echo '</html>'
} > "$OUT/index.html"

touch "$OUT/.nojekyll"
echo "Built $OUT/index.html"
