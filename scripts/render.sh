#!/bin/bash
set -e  # Exit on error

# rendered.sh - Simple CV renderer
# Usage: rendered.sh -p PROFILE [-o OUTPUT_FILE]

# Good defaults
PROFILE=""
OUTPUT=""

# Parse flags
while [[ $# -gt 0 ]]; do
  case $1 in
    -p|--profile)
      PROFILE="$2"
      shift 2
      ;;
    -o|--output)
      OUTPUT="$2"
      shift 2
      ;;
    -h|--help)
      echo "Usage: $0 -p PROFILE [-o OUTPUT_FILE]"
      echo ""
      echo "Generate a tailored resume from tagged YAML"
      echo ""
      echo "Options:"
      echo "  -p, --profile PROFILE   Profile to use (ai, bio, consulting, full)"
      echo "  -o, --output FILE       Output PDF file (default: dist/PROFILE.pdf)"
      echo "  -h, --help              Show this help"
      echo ""
      echo "Examples:"
      echo "  $0 -p ai                     # Creates dist/ai.pdf"
      echo "  $0 -p bio -o resume.pdf      # Creates resume.pdf"
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      echo "Use -h for help"
      exit 1
      ;;
  esac
done

# Validate profile
if [[ -z "$PROFILE" ]]; then
  echo "Error: -p PROFILE is required"
  echo "Use -h for help"
  exit 1
fi

# Set default output if not provided
if [[ -z "$OUTPUT" ]]; then
  OUTPUT="dist/${PROFILE}.pdf"
else
  # If custom output doesn't start with /, put it in dist/
  if [[ "$OUTPUT" != /* ]]; then
    OUTPUT="dist/${OUTPUT}"
  fi
fi

# 1: filter master YAML with branchCV
FILTERED_YAML="build/${PROFILE}.yaml"
mkdir -p build
echo "Filtering CV for profile: $PROFILE"
python3 scripts/branchCV.py data/master_CV.yaml --profile "$PROFILE" --output "$FILTERED_YAML" --verbose

# 2: Render with renderCV
echo "Generating: $OUTPUT"
mkdir -p "$(dirname "$OUTPUT")"
rendercv render "$FILTERED_YAML" \
  --pdf-path "$OUTPUT" \
  --output-folder-name "/tmp/render_tmp" \
  --dont-generate-markdown \
  --dont-generate-html \
  --dont-generate-png

echo "✅ $OUTPUT"
