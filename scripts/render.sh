#!/usr/bin/env bash
# render.sh: Generate a PDF directly from an existing YAML file
# Usage:
#   ./scripts/render.sh -i build/tufts.bio.filtered.yaml -o dist/tufts-bio-resume.pdf
set -euo pipefail

IN=""; OUTPDF=""
while getopts ":i:o:h" opt; do
  case "$opt" in
    i) IN="$OPTARG" ;;
    o) OUTPDF="$OPTARG" ;;
    h) echo "Usage: $0 -i INPUT_YAML -o OUT_PDF"; exit 0 ;;
    *) echo "Bad args"; exit 2 ;;
  esac
done
[[ -n "$IN" && -n "$OUTPDF" ]] || { echo "Missing args"; exit 2; }

command -v rendercv >/dev/null || { echo "Missing: rendercv"; exit 127; }

[[ -f "$IN" ]] || { echo "Input YAML not found: $IN" >&2; exit 1; }
mkdir -p "$(dirname "$OUTPDF")"

# Get a unique temp output folder name based on input file
TEMP_DIR="/tmp/rendercv_tmp_$(basename "$IN" .yaml)"

# Render straight to the requested path; skip HTML/MD/PNG
echo "Rendering $IN to PDF: $OUTPDF"
rendercv render "$IN" \
  --pdf-path "$OUTPDF" \
  --output-folder-name "$TEMP_DIR" \
  --dont-generate-markdown \
  --dont-generate-html \
  --dont-generate-png

echo "✅  $OUTPDF"
