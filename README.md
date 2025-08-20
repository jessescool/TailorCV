# Resume Customization System

A tag-based resume customization system that generates tailored resumes for different professional contexts (AI/ML, bioinformatics, consulting) from a single master file.

## Overview

This system uses a **master CV file with tags** and a **Python filter script** to generate role-specific resumes without maintaining separate files or complex overlays.

## Structure

```
resume/
├── data/
│   └── master_CV.yaml          # Master CV with all content + tags
├── scripts/
│   ├── render.sh               # Simple script to generate resumes
│   └── branchCV.py             # Python filter for tag-based processing
├── build/                      # Intermediate filtered YAML files
├── dist/                       # Generated PDF outputs
└── README.md
```

## How It Works

1. **Master File**: Contains all your content with tags on entries and individual highlights
2. **Profile Definitions**: Each profile specifies which tags to include/exclude
3. **Filter Script**: Processes the master file to create profile-specific YAML
4. **RenderCV**: Generates the final PDF from the filtered YAML

### Tag-Based Filtering

Every section, entry, and highlight can have tags:

```yaml
experience:
  - company: "Tech Company"
    position: "Engineer"
    tags: [ai, engineering, full]          # Entry-level tags
    highlights:
      - text: "Built ML models"
        tags: [ai, ml, python]             # Highlight-level tags
      - text: "Led team of 5"
        tags: [leadership, consulting]     # Different tags per highlight
```

## Usage

### Basic Usage

```bash
scripts/render.sh -p PROFILE [-o OUTPUT]
```

**Required Arguments:**
- `-p PROFILE`: Profile to use ("ai", "bio", "consulting", "full")

**Optional Arguments:**
- `-o OUTPUT`: Output PDF path (default: dist/PROFILE.pdf)

### Examples

```bash
# Generate AI-focused resume (creates dist/ai.pdf)
scripts/render.sh -p ai

# Generate bio research resume with custom name
scripts/render.sh -p bio -o my_bio_resume.pdf

# Generate consulting resume
scripts/render.sh -p consulting -o consulting_resume.pdf

# Generate complete resume with all content
scripts/render.sh -p full
```

## Tagging Examples

### Highlight-Level Tagging Patterns

#### 1. Technical vs Management highlights
```yaml
highlights:
  - text: "Led team of 5 engineers to deliver project on time"
    tags: [leadership, management, consulting]
  - text: "Implemented machine learning pipeline in Python"
    tags: [ai, python, engineering]
  - text: "Reduced processing time by 40% through algorithm optimization"
    tags: [ai, engineering, performance]
```

#### 2. Different technical domains
```yaml
highlights:
  - text: "Developed web application using React and Node.js"
    tags: [web, frontend, backend]
  - text: "Built deep learning model for protein structure prediction"
    tags: [ai, bio, ml, research]
  - text: "Implemented distributed system with Kubernetes"
    tags: [devops, cloud, engineering]
```

#### 3. Audience-specific versions of same work
```yaml
highlights:
  - text: "Analyzed biological data using machine learning techniques"
    tags: [bio, research]  # For bio audience
  - text: "Built ML pipeline with 95% accuracy for protein analysis"
    tags: [ai, ml, engineering]  # For AI audience
  - text: "Delivered data science solution for client research team"
    tags: [consulting, data]  # For consulting audience
```

#### 4. Soft skills vs technical skills
```yaml
highlights:
  - text: "Mentored 3 junior developers in best practices"
    tags: [leadership, education, consulting]
  - text: "Optimized database queries reducing latency by 60%"
    tags: [engineering, performance, backend]
  - text: "Presented findings to C-level executives"
    tags: [consulting, communication, leadership]
```

### Entry-Level Tagging Examples

#### 1. Whole job experiences
```yaml
experience:
  - company: "Tech Startup"
    position: "Senior Engineer"
    tags: [ai, startup, leadership]  # ← Entire job tagged
    highlights: [...]

  - company: "Consulting Firm"
    position: "Data Scientist"
    tags: [consulting, client-work]  # ← Different entry, different tags
    highlights: [...]

  - company: "University Lab"
    position: "Research Assistant"
    tags: [research, academic, bio]  # ← Academic experience
    highlights: [...]
```

#### 2. Side projects vs main projects
```yaml
projects:
  - name: "Production ML System"
    tags: [ai, production, engineering]  # ← Professional project
    highlights: [...]

  - name: "Personal Blog"
    tags: [personal, web, writing]       # ← Personal project
    highlights: [...]

  - name: "Open Source Contribution"
    tags: [oss, community, engineering]  # ← Community work
    highlights: [...]
```

#### 3. Different education levels
```yaml
education:
  - institution: "MIT"
    degree: "PhD"
    tags: [research, academic, advanced]  # ← Advanced degree
    highlights: [...]

  - institution: "State University"
    degree: "BS"
    tags: [undergraduate, foundation]     # ← Undergrad
    highlights: [...]

  - institution: "Coding Bootcamp"
    tags: [practical, career-change]      # ← Alternative education
    highlights: [...]
```

#### 4. Industry-specific vs general skills
```yaml
technologies:
  - label: "Machine Learning"
    details: "TensorFlow, PyTorch, scikit-learn"
    tags: [ai, ml, research]             # ← AI-specific

  - label: "Web Development"
    details: "React, Node.js, PostgreSQL"
    tags: [web, frontend, backend]       # ← Web-specific

  - label: "General Programming"
    details: "Python, Git, Linux"
    tags: [engineering, general]         # ← Universal skills
```

## Profile System

The system includes four built-in profiles:

### `ai` - AI/ML Engineer
- **Includes**: ai, ml, pytorch, python, research, academic, programming, tools, systems
- **Focus**: Machine learning, research, technical skills
- **Sections**: All sections included

### `bio` - Bioinformatics Researcher  
- **Includes**: bio, research, academic, publication, python, ai, ml, programming, tools, systems
- **Focus**: Biological research, publications, computational biology
- **Sections**: All sections included

### `consulting` - Strategy/Leadership
- **Includes**: consulting, leadership, teaching, communication, academic, resilience, math, programming, tools, systems
- **Focus**: Leadership, communication, problem-solving
- **Sections**: Excludes publications

### `full` - Complete Resume
- **Includes**: Everything tagged with "full"
- **Focus**: Complete professional history
- **Sections**: All sections included

## Adding Content

### Tagging Strategy

1. **Entry-Level Tags**: Tag entire experiences, projects, or education entries
2. **Highlight-Level Tags**: Tag individual bullet points for granular control
3. **Universal Content**: Use `[full]` tag for content that should appear in all resumes
4. **Specific Content**: Use profile-specific tags like `[ai]`, `[bio]`, `[consulting]`

### Example Entry

```yaml
experience:
  - company: "Research Lab"
    position: "Researcher"
    tags: [ai, bio, research, full]
    highlights:
      - text: "Published paper on protein folding"
        tags: [bio, research, publication, full]
      - text: "Built ML pipeline in PyTorch"
        tags: [ai, ml, pytorch, engineering, full]
      - text: "Managed team of junior researchers"
        tags: [leadership, consulting, full]
```

## Requirements

- Python 3.7+
- PyYAML (`pip install pyyaml`)
- RenderCV (`pip install rendercv[full]`)

## Customization

You can modify the profile definitions in `data/master_CV.yaml` under the `profiles:` section to:
- Add new profiles
- Modify tag inclusion/exclusion rules
- Change which sections appear in each profile
- Control whether untagged content is included

## Files Generated

- `build/PROFILE.yaml` - Intermediate filtered YAML for each profile
- `dist/PROFILE.pdf` or custom output path - Final PDF resume

The tag-based system provides fine-grained control over content while maintaining a single source of truth for all your professional information.
