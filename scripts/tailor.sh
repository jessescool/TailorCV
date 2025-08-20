#!/usr/bin/env bash
# YAML-only forks: filter by profile tags, overlay diffs, render PDF
# Usage:
#   ./scripts/tailor.sh -r recursion-ml -p ai -o dist/jesse-recursion-ml-ai.pdf
set -euo pipefail

ROLE=""; PROFILE=""; IN="data/base_CV.yaml"; OUTPDF=""
while getopts ":r:p:i:o:h" opt; do
  case "$opt" in
    r) ROLE="$OPTARG" ;;
    p) PROFILE="$OPTARG" ;;
    i) IN="$OPTARG" ;;
    o) OUTPDF="$OPTARG" ;;
    h) echo "Usage: $0 -r ROLE [-p PROFILE] [-i BASE_CV_YAML] [-o OUT_PDF]"; exit 0 ;;
    *) echo "Bad args"; exit 2 ;;
  esac
done
[[ -n "$ROLE" ]] || { echo "Missing required arg (-r)"; exit 2; }

# Set default output filename if not provided
if [[ -z "$OUTPDF" ]]; then
  if [[ -n "$PROFILE" ]]; then
    OUTPDF="dist/${ROLE}-${PROFILE}.pdf"
  else
    OUTPDF="dist/${ROLE}-base.pdf"
  fi
  echo "Using default output path: $OUTPDF"
fi

for cmd in yq rendercv; do command -v "$cmd" >/dev/null || { echo "Missing: $cmd"; exit 127; }; done

ROOT="$(pwd)"; BUILD="$ROOT/build"

# Skip overlay merging if no profile is specified
if [[ -n "$PROFILE" ]]; then
  OVL="$ROOT/overlays/${PROFILE}.yaml"
  [[ -f "$OVL" ]] || { echo "Overlay not found: $OVL" >&2; exit 1; }
fi

[[ -f "$IN" ]] || { echo "Base CV YAML not found: $IN" >&2; exit 1; }
mkdir -p "$BUILD" "$(dirname "$OUTPDF")"

# 1) Merge base + overlay (deep-merge; overlay wins) if profile is specified
if [[ -n "$PROFILE" ]]; then
  MERGED="$BUILD/${ROLE}.${PROFILE}.merged.yaml"
  echo "Merging $IN and $OVL into $MERGED"
  yq eval-all 'select(fileIndex==0) * select(fileIndex==1)' "$IN" "$OVL" > "$MERGED"
else
  # Just use the base file if no profile specified
  MERGED="$BUILD/${ROLE}.base.merged.yaml"
  echo "Using $IN as $MERGED (no profile specified)"
  cp "$IN" "$MERGED"
fi

# 2) Filter entries by profile tag for sections that are lists
#    Keep items with (.profiles missing) OR (.profiles includes PROFILE)
FILTERED="$BUILD/${ROLE}.${PROFILE:-base}.filtered.yaml"
echo "Creating filtered file: $FILTERED"
cp "$MERGED" "$FILTERED"

# For "all" profile or when no profile is specified, skip filtering and just remove the profiles tags
if [[ -z "$PROFILE" || "$PROFILE" == "all" ]]; then
  # Just remove all profiles tags without filtering
  yq eval -i '.cv.sections.experience |= map(del(.profiles))' "$FILTERED"
  yq eval -i '.cv.sections.projects |= map(del(.profiles))' "$FILTERED"
  yq eval -i '.cv.sections.publications |= map(del(.profiles))' "$FILTERED"
else
  # Apply filtering to specific sections we know are lists
  yq eval -i '.cv.sections.experience |= map(select(has("profiles") | not or .profiles[] == "'"$PROFILE"'"))' "$FILTERED"
  yq eval -i '.cv.sections.projects |= map(select(has("profiles") | not or .profiles[] == "'"$PROFILE"'"))' "$FILTERED"
  yq eval -i '.cv.sections.publications |= map(select(has("profiles") | not or .profiles[] == "'"$PROFILE"'"))' "$FILTERED"
  
  # Remove all profiles tags
  yq eval -i '.cv.sections.experience |= map(del(.profiles))' "$FILTERED"
  yq eval -i '.cv.sections.projects |= map(del(.profiles))' "$FILTERED"
  yq eval -i '.cv.sections.publications |= map(del(.profiles))' "$FILTERED"
fi

# 3) Render straight to the requested path; skip HTML/MD/PNG (settings + flags)
echo "Rendering PDF to $OUTPDF"
rendercv render "$FILTERED" \
  --pdf-path "$OUTPDF" \
  --output-folder-name "/tmp/rendercv_tmp_${ROLE}_${PROFILE:-base}" \
  --dont-generate-markdown \
  --dont-generate-html \
  --dont-generate-png

echo "✅  $OUTPDF"
