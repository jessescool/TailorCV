#!/usr/bin/env python3
"""
tailorCV - Filter tagged YAML by profile

Pure filtering tool: takes tagged YAML, applies profile, outputs clean YAML.
"""

import yaml
import sys
import argparse
from copy import deepcopy

def should_include_item(item, profile_tag):
    """Check if an item should be included based on its tags and profile tag."""
    if not isinstance(item, dict):
        return True
    
    item_tags = item.get('tags', [])
    
    # Always include untagged items
    if not item_tags:
        return True
    
    # Include if the profile tag is in the item's tags
    return profile_tag in item_tags

def filter_highlights(highlights, profile_tag):
    """Filter highlights list, converting tagged highlights to plain strings."""
    if not isinstance(highlights, list):
        return highlights
    
    filtered_highlights = []
    
    for highlight in highlights:
        if isinstance(highlight, dict) and 'text' in highlight:
            # This is a tagged highlight with text and tags
            if should_include_item(highlight, profile_tag):
                # Keep just the text content, removing tags
                filtered_highlights.append(highlight['text'])
        elif isinstance(highlight, str):
            # This is a plain string highlight - always include (untagged)
            filtered_highlights.append(highlight)
        else:
            # Other format, check for tags
            if should_include_item(highlight, profile_tag):
                # Remove tags if present
                if isinstance(highlight, dict) and 'tags' in highlight:
                    clean_highlight = {k: v for k, v in highlight.items() if k != 'tags'}
                    filtered_highlights.append(clean_highlight)
                else:
                    filtered_highlights.append(highlight)
    
    return filtered_highlights

def filter_data(data, profile_tag):
    """Recursively filter data structure based on profile tag."""
    if isinstance(data, dict):
        filtered_data = {}
        for key, value in data.items():
            if key == 'tags':
                # Skip tags field in output
                continue
            elif key == 'highlights':
                # Special handling for highlights
                filtered_value = filter_highlights(value, profile_tag)
                if filtered_value:  # Only include if not empty
                    filtered_data[key] = filtered_value
            elif isinstance(value, list):
                # Regular list filtering
                filtered_value = filter_list(value, profile_tag)
                if filtered_value:  # Only include if not empty
                    filtered_data[key] = filtered_value
            elif isinstance(value, dict):
                # Recursive dict filtering
                filtered_value = filter_data(value, profile_tag)
                if filtered_value:  # Only include if not empty
                    filtered_data[key] = filtered_value
            else:
                # Primitive values
                filtered_data[key] = value
        return filtered_data
    elif isinstance(data, list):
        return filter_list(data, profile_tag)
    else:
        return data

def filter_list(items, profile_tag):
    """Filter a list of items based on tags."""
    if not isinstance(items, list):
        return items
    
    filtered_items = []
    
    for item in items:
        if isinstance(item, dict):
            # Check if this item should be included
            if should_include_item(item, profile_tag):
                # Process the item recursively
                filtered_item = filter_data(item, profile_tag)
                if filtered_item:  # Only include if not empty
                    filtered_items.append(filtered_item)
        else:
            # Non-dict items (like strings) are always included
            filtered_items.append(item)
    
    return filtered_items

def filter_sections(cv_data, profile_tag):
    """Filter sections based on tags."""
    sections = cv_data.get('sections', {})
    filtered_sections = {}
    
    for section_name, section_data in sections.items():
        # Filter the section data
        filtered_section = filter_data(section_data, profile_tag)
        if filtered_section:  # Only include if not empty
            filtered_sections[section_name] = filtered_section
    
    return filtered_sections

def main():
    parser = argparse.ArgumentParser(description='Filter tagged YAML by profile')
    parser.add_argument('input_file', help='Input master YAML file')
    parser.add_argument('--profile', '-p', required=True, help='Profile name to filter by')
    parser.add_argument('--output', '-o', help='Output file (default: stdout)')
    parser.add_argument('--verbose', '-v', action='store_true', help='Verbose output')
    
    args = parser.parse_args()
    
    try:
        with open(args.input_file, 'r') as f:
            data = yaml.safe_load(f)
    except FileNotFoundError:
        print(f"Error: File {args.input_file} not found", file=sys.stderr)
        sys.exit(1)
    except yaml.YAMLError as e:
        print(f"Error parsing YAML: {e}", file=sys.stderr)
        sys.exit(1)
    
    # Get profile tag
    profiles = data.get('profiles', {})
    if args.profile not in profiles:
        print(f"Error: Profile '{args.profile}' not found in input file", file=sys.stderr)
        print(f"Available profiles: {list(profiles.keys())}", file=sys.stderr)
        sys.exit(1)
    
    profile_tag = profiles[args.profile]
    
    if args.verbose:
        print(f"Loaded master YAML: {args.input_file}", file=sys.stderr)
        print(f"Applying profile: {args.profile} (tag: {profile_tag})", file=sys.stderr)
    
    # Create filtered data
    output_data = deepcopy(data)
    
    # Remove profiles section from output
    if 'profiles' in output_data:
        del output_data['profiles']
    
    # Filter sections
    if 'cv' in output_data and 'sections' in output_data['cv']:
        filtered_sections = filter_sections(output_data['cv'], profile_tag)
        output_data['cv']['sections'] = filtered_sections
    
    # Output filtered data
    output_yaml = yaml.dump(output_data, default_flow_style=False, sort_keys=False, width=float('inf'))
    
    if args.output:
        with open(args.output, 'w') as f:
            f.write(output_yaml)
        if args.verbose:
            print(f"Filtered YAML written to: {args.output}", file=sys.stderr)
    else:
        print(output_yaml)

if __name__ == '__main__':
    main()
