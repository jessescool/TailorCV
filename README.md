# TailorCV

Tag-based resume customization for [RenderCV](https://github.com/rendercv/rendercv). 
Generate multiple targeted resumes from one master CV file.

## Setup

1. Install RenderCV: `pip install rendercv[full]` ([docs](https://docs.rendercv.com))
2. Download this code.
2. Make a YAML file in accordance with RenderCV's formatting ([see Formatting](#formatting))
3. Add tags

4. Ready:

```bash
# Generate profiles
./scripts/render.sh -p ai          # AI/ML resume
./scripts/render.sh -p bio         # Research resume  
./scripts/render.sh -p consulting  # Consulting resume
./scripts/render.sh -p default     # Complete resume
```

## Formatting

Tag content in your CV YAML to control where it appears:

```yaml
experience:
  - company: "Research Lab"
    tags: [ai, bio, default]
    highlights:
      - text: "Built ML models"
        tags: [ai, default]
      - text: "Published research"
        tags: [bio, default]
      - text: "Led team of 5"
        tags: [consulting, default]
      - "Collaborated across departments"  # Untagged = appears everywhere
```

**Profiles:**
- `ai: ai` - AI/ML roles
- `bio: bio` - Research/academia  
- `consulting: consulting` - Leadership roles
- `default: default` - Complete resume

## Usage

```bash
# Basic usage
./scripts/render.sh -p PROFILE

# Custom CV file
./scripts/render.sh your_cv.yaml -p PROFILE

# Custom output
./scripts/render.sh -p PROFILE -o custom-name.pdf
```

**Note:** Assumes your file is called `master_CV.yaml`. To use a different file, specify it as the first argument:

```bash
./scripts/render.sh SOURCE.yaml -p PROFILE -o custom-name.pdf
```

**Rules:**
- Tagged items only appear in matching profiles
- Untagged items appear everywhere
- All tags removed from final output

Works with any RenderCV theme and preserves all formatting.
