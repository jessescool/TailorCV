# Resume Customization System

A YAML-based resume customization system that lets you maintain a single base resume and generate tailored versions for different professional contexts (AI, bio, consulting, etc.).

## Overview

This system uses:
- A base YAML file with all your experience, projects, and skills
- Profile-specific overlay YAML files for customizations
- A tailor script that merges, filters, and renders the final PDFs

## Directory Structure

```
resume/
├── build/                  # Intermediate YAML files during processing
├── data/
│   └── base_CV.yaml        # Your comprehensive base resume
├── dist/                   # Generated PDF outputs
├── overlays/
│   ├── ai.yaml             # AI profile customizations
│   ├── bio.yaml            # Bio profile customizations
│   └── consulting.yaml     # Consulting profile customizations
└── scripts/
    ├── tailor.sh           # Main processing script
    └── render.sh           # Script to render directly from YAML
```

## Requirements

- [yq](https://github.com/mikefarah/yq) - YAML processor
- [rendercv](https://github.com/rendercv/rendercv) - Resume PDF generator

## Usage

### Full Pipeline (Merge, Filter, and Render)

Basic command structure:

```bash
./scripts/tailor.sh -r ROLE -p PROFILE -o OUTPUT_PDF
```

Where:
- `-r ROLE`: An identifier for this specific version (e.g., "google", "meta")
- `-p PROFILE`: The profile to use (must match an overlay file name without extension)
- `-i BASE_YAML`: (Optional) Path to your base resume (defaults to "data/base_CV.yaml")
- `-o OUTPUT_PDF`: Path to save the generated PDF

### Direct Rendering from YAML

If you've already created a filtered YAML file or made manual adjustments to a YAML file:

```bash
./scripts/render.sh -i INPUT_YAML -o OUTPUT_PDF
```

Where:
- `-i INPUT_YAML`: Path to the YAML file to render (e.g., "build/harvard.bio.filtered.yaml")
- `-o OUTPUT_PDF`: Path to save the generated PDF

### Example Commands

```bash
# Generate an AI-focused resume for Google
./scripts/tailor.sh -r google -p ai -o dist/resume-google-ai.pdf

# Generate a bio-focused resume for academia
./scripts/tailor.sh -r academia -p bio -o dist/resume-academia-bio.pdf

# Generate a consulting-focused resume
./scripts/tailor.sh -r mckinsey -p consulting -o dist/resume-mckinsey-consulting.pdf

# Render directly from a previously filtered or manually edited YAML file
./scripts/render.sh -i build/harvard.bio.filtered.yaml -o dist/harvard-bio-direct.pdf

# Using custom base YAML file
./scripts/tailor.sh -r custom -p ai -i my-custom-base.yaml -o dist/custom-ai.pdf
```

## How to Structure Your YAML Files

### Base Resume (`data/base_CV.yaml`)

Include all your experience, projects, skills, etc. Tag entries with the `profiles` field to indicate which profiles they should appear in:

```yaml
cv:
  name: "Your Name"
  label: "Professional Title"
  location: "City, State, Country"
  email: "you@example.com"
  sections:
    experience:
      - company: "AI Research Lab"
        position: "ML Engineer"
        profiles: [ai, research]  # Will appear in ai and research profiles
        highlights:
          - "Built deep learning models..."

      - company: "Consulting Firm"
        position: "Associate"
        profiles: [consulting]  # Will only appear in consulting profile
        highlights:
          - "Led client engagements..."

      - company: "University Teaching"
        # No profiles tag means it will appear in ALL profiles
        highlights:
          - "Taught programming courses..."
```

### Profile Overlays (`overlays/*.yaml`)

Create profile-specific customizations that will be merged with your base resume:

```yaml
# overlays/ai.yaml
cv:
  label: "Machine Learning Engineer"  # Override the job title for AI roles
  sections:
    summary:
      - "AI specialist with expertise in deep learning and NLP"  # Custom summary for AI roles
```

## How It Works

1. **Merging**: The base resume is merged with a profile overlay
2. **Filtering**: Entries are filtered based on the "profiles" tag
3. **Cleanup**: The "profiles" tags are removed from the final output
4. **Rendering**: The filtered YAML is rendered to PDF using rendercv

## Best Practices

1. **Keep the base YAML comprehensive**: Include all your experiences, then tag them with appropriate profiles
2. **Use overlays for targeted customization**: Change summary, job title, or add profile-specific content
3. **Entries without a `profiles` tag**: These will appear in all versions of your resume
4. **Test different profiles**: Run the script with different profiles to ensure content filtering works as expected
5. **Backup before changes**: Keep a copy of your base YAML before making significant changes

## Advanced Tips

1. **Nested entries** might need additional tagging in the YAML structure
2. **Multiple profiles** can be specified with `profiles: [ai, research, academic]`
3. **Empty profiles** array would hide an entry from all profiles
4. **The build directory** contains intermediate files if you need to debug

## Troubleshooting

If you encounter issues:

1. Check the intermediate YAML files in the `build/` directory
2. Ensure your YAML syntax is correct in both base and overlay files
3. Verify that yq and rendercv are installed and accessible in your PATH
4. Make sure your profile name matches the overlay filename (without extension)
