#!/usr/bin/env bash
# New tag-based resume generator using rendercv_filter.py
# Usage:
#   ./scripts/tailor_v2.sh -r role-name -p profile [-o output.pdf]
set -euo pipefail

ROLE=""; PROFILE=""; OUTPDF=""
MASTER="data/master_CV.yaml"

while getopts ":r:p:o:h" opt; do
  case "$opt" in
    r) ROLE="$OPTARG" ;;
    p) PROFILE="$OPTARG" ;;
    o) OUTPDF="$OPTARG" ;;
    h) echo "Usage: $0 -r ROLE -p PROFILE [-o OUT_PDF]"
       echo "Profiles: ai, bio, consulting, full"
       exit 0 ;;
    *) echo "Bad args"; exit 2 ;;
  esac
done

[[ -n "$ROLE" ]] || { echo "Missing required arg (-r ROLE)"; exit 2; }
[[ -n "$PROFILE" ]] || { echo "Missing required arg (-p PROFILE)"; exit 2; }

# Set default output filename if not provided
if [[ -z "$OUTPDF" ]]; then
  OUTPDF="dist/${ROLE}-${PROFILE}.pdf"
  echo "Using default output path: $OUTPDF"
fi

# Check dependencies
for cmd in python3 rendercv; do 
  command -v "$cmd" >/dev/null || { echo "Missing: $cmd"; exit 127; }
done

ROOT="$(pwd)"; BUILD="$ROOT/build"
mkdir -p "$BUILD" "$(dirname "$OUTPDF")"

# Generate filtered YAML using Python script
FILTERED="$BUILD/${ROLE}-${PROFILE}.yaml"
echo "Filtering master CV for profile '$PROFILE'..."

python3 scripts/rendercv_filter.py "$MASTER" --profile "$PROFILE" --out "$FILTERED" --verbose

if [[ ! -f "$FILTERED" ]]; then
  echo "Error: Failed to generate filtered YAML"
  exit 1
fi

echo "Generated filtered YAML: $FILTERED"

# Render PDF with RenderCV
echo "Rendering PDF with RenderCV..."
rendercv render "$FILTERED" --output-folder-name "$(dirname "$OUTPDF")" --pdf-path "$(basename "$OUTPDF")"

echo "✅ Generated: $OUTPDF"
