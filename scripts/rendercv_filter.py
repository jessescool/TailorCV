#!/usr/bin/env python3
"""
RenderCV Filter Script

Filters a master YAML file based on profile rules and outputs a clean RenderCV-ready YAML.
Supports tag-based filtering at both section and item level.
"""

import yaml
import argparse
import sys
from pathlib import Path
from typing import Dict, List, Any, Optional


def should_include_item(item: Any, profile: Dict[str, Any]) -> bool:
    """
    Check if an item should be included based on profile rules.
    
    Args:
        item: The item to check (can be dict with tags or plain string/other)
        profile: Profile configuration with include_tags, exclude_tags, include_untagged
    
    Returns:
        bool: True if item should be included
    """
    # If item is not a dict or has no tags, treat as untagged
    if not isinstance(item, dict) or 'tags' not in item:
        return profile.get('include_untagged', True)
    
    item_tags = set(item.get('tags', []))
    exclude_tags = set(profile.get('exclude_tags', []))
    include_tags = set(profile.get('include_tags', []))
    
    # If item has any excluded tag, exclude it
    if item_tags & exclude_tags:
        return False
    
    # If include_tags is specified and non-empty
    if include_tags:
        # Keep only if item has at least one included tag
        return bool(item_tags & include_tags)
    
    # If no include_tags specified, include by default (unless excluded above)
    return True


def clean_tags_from_item(item: Any) -> Any:
    """Remove tags from an item."""
    if isinstance(item, dict) and 'tags' in item:
        return {k: v for k, v in item.items() if k != 'tags'}
    return item


def filter_highlights(highlights: List[Any], profile: Dict[str, Any]) -> List[Any]:
    """Filter highlights/bullets list based on profile rules."""
    filtered_highlights = []
    
    for highlight in highlights:
        if isinstance(highlight, dict) and 'text' in highlight:
            # This is a tagged highlight with text and tags
            if should_include_item(highlight, profile):
                # Keep just the text content, removing tags
                filtered_highlights.append(highlight['text'])
        elif isinstance(highlight, str):
            # This is a plain string highlight - keep if include_untagged is True
            if profile.get('include_untagged', True):
                filtered_highlights.append(highlight)
        else:
            # Other format, check for tags
            if should_include_item(highlight, profile):
                filtered_highlights.append(clean_tags_from_item(highlight))
    
    return filtered_highlights


def filter_section_content(content: Any, profile: Dict[str, Any]) -> Any:
    """
    Recursively filter section content, looking for filterable lists.
    """
    if isinstance(content, dict):
        filtered_content = {}
        for key, value in content.items():
            if key == 'tags':
                # Skip tags at section level
                continue
            elif key == 'highlights' and isinstance(value, list):
                # Filter highlights specially
                filtered_content[key] = filter_highlights(value, profile)
            elif key in ['bullets', 'items'] and isinstance(value, list):
                # Filter other special lists (but not authors, which is just a list of strings)
                filtered_items = []
                for item in value:
                    if should_include_item(item, profile):
                        filtered_items.append(clean_tags_from_item(item))
                filtered_content[key] = filtered_items
            elif key == 'authors' and isinstance(value, list):
                # Authors list should be preserved as-is
                filtered_content[key] = value
            elif isinstance(value, (dict, list)):
                # Recursively filter nested structures
                filtered_value = filter_section_content(value, profile)
                if filtered_value is not None:  # Only include non-None results
                    filtered_content[key] = filtered_value
            else:
                filtered_content[key] = value
        return filtered_content
    elif isinstance(content, list):
        # Filter list items
        filtered_list = []
        for item in content:
            if should_include_item(item, profile):
                filtered_item = filter_section_content(clean_tags_from_item(item), profile)
                if filtered_item:  # Only include non-empty results
                    filtered_list.append(filtered_item)
        return filtered_list
    else:
        return content


def filter_yaml(data: Dict[str, Any], profile_name: str) -> Dict[str, Any]:
    """
    Filter the master YAML data based on the specified profile.
    
    Args:
        data: The loaded YAML data
        profile_name: Name of the profile to apply
    
    Returns:
        Filtered YAML data ready for RenderCV
    """
    if 'profiles' not in data:
        raise ValueError("No 'profiles' section found in master YAML")
    
    if profile_name not in data['profiles']:
        raise ValueError(f"Profile '{profile_name}' not found in profiles section")
    
    profile = data['profiles'][profile_name]
    
    # Start with a copy of the original data
    filtered_data = dict(data)
    
    # Remove the profiles section from output
    del filtered_data['profiles']
    
    # Process sections if they exist in cv
    if 'cv' in filtered_data and 'sections' in filtered_data['cv']:
        include_sections = set(profile.get('include_sections', []))
        exclude_sections = set(profile.get('exclude_sections', []))
        
        sections = filtered_data['cv']['sections']
        filtered_sections = {}
        
        for section_name, section_content in sections.items():
            # Check section-level inclusion/exclusion
            if exclude_sections and section_name in exclude_sections:
                continue
            
            if include_sections and section_name not in include_sections:
                continue
            
            # Check section-level tags if it's a dict with tags
            if isinstance(section_content, dict) and not should_include_item(section_content, profile):
                continue
            
            # Filter the section content
            filtered_content = filter_section_content(section_content, profile)
            if filtered_content:  # Only include non-empty sections
                filtered_sections[section_name] = filtered_content
        
        filtered_data['cv']['sections'] = filtered_sections
    
    return filtered_data


def main():
    parser = argparse.ArgumentParser(description='Filter RenderCV master YAML by profile')
    parser.add_argument('input_file', help='Path to master YAML file')
    parser.add_argument('--profile', '-p', required=True, help='Profile name to apply')
    parser.add_argument('--out', '-o', help='Output file path (default: stdout)')
    parser.add_argument('--verbose', '-v', action='store_true', help='Verbose output')
    
    args = parser.parse_args()
    
    try:
        # Load master YAML
        with open(args.input_file, 'r') as f:
            data = yaml.safe_load(f)
        
        if args.verbose:
            print(f"Loaded master YAML: {args.input_file}", file=sys.stderr)
            print(f"Applying profile: {args.profile}", file=sys.stderr)
        
        # Filter based on profile
        filtered_data = filter_yaml(data, args.profile)
        
        # Output filtered YAML
        if args.out:
            with open(args.out, 'w') as f:
                yaml.dump(filtered_data, f, default_flow_style=False, sort_keys=False)
            if args.verbose:
                print(f"Filtered YAML written to: {args.out}", file=sys.stderr)
        else:
            yaml.dump(filtered_data, sys.stdout, default_flow_style=False, sort_keys=False)
    
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == '__main__':
    main()
