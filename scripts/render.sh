#!/bin/bash
set -e  # Exit on error

# rendered.sh - Simple CV renderer
# Usage: rendered.sh [YAML_FILE] -p PROFILE [-o OUTPUT_FILE]

# Good defaults
INPUT_FILE=""
PROFILE=""
OUTPUT=""

# Parse positional and flags
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
      echo "Usage: $0 [YAML_FILE] [-p PROFILE] [-o OUTPUT_FILE]"
      echo ""
      echo "Generate a tailored resume from tagged YAML"
      echo ""
      echo "Arguments:"
      echo "  YAML_FILE               Input YAML file (default: data/master_CV.yaml)"
      echo ""
      echo "Options:"
      echo "  -p, --profile PROFILE   Profile to use (default: default)"
      echo "  -o, --output FILE       Output PDF file (default: dist/PROFILE.pdf)"
      echo "  -h, --help              Show this help"
      echo ""
      echo "Examples:"
      echo "  $0 -p ai                           # Uses data/master_CV.yaml, creates dist/ai.pdf"
      echo "  $0 other.yaml -p bio               # Uses other.yaml, creates dist/bio.pdf"
      echo "  $0 -p ai -o my-resume.pdf          # Creates dist/my-resume.pdf"
      exit 0
      ;;
    -*)
      echo "Unknown option: $1"
      echo "Use -h for help"
      exit 1
      ;;
    *)
      # This is the positional argument (YAML file)
      if [[ -z "$INPUT_FILE" ]]; then
        INPUT_FILE="$1"
      else
        echo "Error: Multiple YAML files specified"
        echo "Use -h for help"
        exit 1
      fi
      shift
      ;;
  esac
done

# Set default input file if not provided
if [[ -z "$INPUT_FILE" ]]; then
  INPUT_FILE="data/master_CV.yaml"
fi

# Set default profile if not provided
if [[ -z "$PROFILE" ]]; then
  PROFILE="default"
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

# 1: filter master YAML with tailorCV
FILTERED_YAML="build/${PROFILE}.yaml"
mkdir -p build
echo "Filtering CV for profile: $PROFILE (from: $INPUT_FILE)"
python3 scripts/tailorCV.py "$INPUT_FILE" --profile "$PROFILE" --output "$FILTERED_YAML" --verbose

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
