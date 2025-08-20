# Customizing Resume Themes in RenderCV

RenderCV offers several built-in themes that you can use to customize the appearance of your resume. This guide explains how to select and customize themes for your resume.

## Available Themes

RenderCV provides the following built-in themes:

1. **classic** - A clean, professional theme with a traditional layout
2. **sb2nov** - Inspired by Sourabh Bajaj's resume template
3. **engineeringresumes** - A theme optimized for engineering resumes
4. **engineeringclassic** - A classic engineering theme
5. **moderncv** - A modern CV theme inspired by the LaTeX moderncv package

You can preview how these themes look on the [RenderCV documentation](https://docs.rendercv.com/).

## How to Select a Theme

To select a theme, add a `design` section to your YAML file with the `theme` property:

```yaml
design:
  theme: moderncv  # Choose from: classic, sb2nov, engineeringresumes, engineeringclassic, moderncv
```

## Using Themes with the Tailor Script

You can specify a theme in your base YAML file or in a profile overlay.

### Option 1: Add theme to your base_CV YAML file

```yaml
# data/base_CV.yaml
cv:
  name: "Jesse Yourlastname"
  # ...other resume content
design:
  theme: classic
```

### Option 2: Add theme to a profile overlay

```yaml
# overlays/ai.yaml
cv:
  label: "AI/ML for Biology"
design:
  theme: moderncv
```

## Advanced Theme Customization

You can customize many aspects of a theme by adding properties to the `design` section:

```yaml
design:
  theme: classic  # Base theme
  
  # Page properties
  page:
    size: us-letter  # Options: a4, us-letter, etc.
    top_margin: 2cm
    bottom_margin: 2cm
    left_margin: 2cm
    right_margin: 2cm
    
  # Color scheme
  colors:
    text: black
    name: '#004f90'  # Header name color
    section_titles: '#004f90'
    links: '#004f90'
    
  # Font properties
  text:
    font_family: "Source Sans 3"  # Many options available
    font_size: 10pt
    alignment: justified  # Options: left, justified, justified-with-no-hyphenation
    
  # Section title styling
  section_titles:
    font_size: 1.4em
    bold: true
    small_caps: false
    
  # Highlight bullet styling
  highlights:
    bullet: "•"  # Options: •, ◦, -, ◆, ★, ■, —, ○
```

## Testing Different Themes

To test different themes without modifying your base files, you can create a temporary YAML file with different design options and use the `render.sh` script:

1. Create a file `test-theme.yaml` by copying your filtered YAML and adding design options
2. Run: `./scripts/render.sh -i test-theme.yaml -o dist/test-theme.pdf`

## Theme Examples

Here are examples of setting up different themes:

### Modern CV Theme

```yaml
design:
  theme: moderncv
  colors:
    name: '#1A237E'  # Dark blue
    section_titles: '#1A237E'
```

### Engineering Theme

```yaml
design:
  theme: engineeringresumes
  text:
    font_family: "Roboto"
  section_titles:
    font_size: 1.2em
```

## Creating Custom Themes

If you want to create a completely custom theme:

1. Start with an existing theme as your base
2. Customize all the design parameters to your liking
3. For advanced customization, you can follow the [RenderCV documentation on creating custom themes](https://docs.rendercv.com/user_guide/faq/#how-to-create-a-custom-theme)

## RenderCV Web Resources

- [RenderCV App](https://rendercv.com/) - Online editor with theme preview
- [RenderCV Documentation](https://docs.rendercv.com/) - Full documentation
- [GitHub Repository](https://github.com/rendercv/rendercv) - Source code and examples
