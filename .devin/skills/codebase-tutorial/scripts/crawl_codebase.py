#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# ///
"""
Crawl a codebase (local directory or GitHub repo) and output file contents as JSON.

This is the deterministic "fetch" step of the codebase tutorial pipeline.
"""

import argparse
import fnmatch
import json
import os
import sys
from pathlib import Path
from typing import Optional
from urllib.parse import urlparse

try:
    import requests
    HAS_REQUESTS = True
except ImportError:
    HAS_REQUESTS = False


def should_include_file(
    filepath: str,
    include_patterns: list[str],
    exclude_patterns: list[str],
) -> bool:
    """Check if file matches include patterns and doesn't match exclude patterns."""
    filename = os.path.basename(filepath)

    included = False
    for pattern in include_patterns:
        if fnmatch.fnmatch(filepath, pattern) or fnmatch.fnmatch(filename, pattern):
            included = True
            break

    if not included:
        return False

    for pattern in exclude_patterns:
        if fnmatch.fnmatch(filepath, pattern) or fnmatch.fnmatch(filename, pattern):
            return False

    return True


def is_binary_file(filepath: str) -> bool:
    """Check if file appears to be binary."""
    try:
        with open(filepath, 'rb') as f:
            chunk = f.read(8192)
            if b'\x00' in chunk:
                return True
        return False
    except Exception:
        return True


def crawl_local_directory(
    directory: str,
    include_patterns: list[str],
    exclude_patterns: list[str],
    max_file_size: int,
    use_relative_paths: bool = True,
) -> dict:
    """Crawl a local directory and return file contents."""
    directory = os.path.abspath(directory)
    files = {}

    for root, dirs, filenames in os.walk(directory):
        dirs[:] = [d for d in dirs if not d.startswith('.')]

        for filename in filenames:
            if filename.startswith('.'):
                continue

            filepath = os.path.join(root, filename)

            if use_relative_paths:
                rel_path = os.path.relpath(filepath, directory)
            else:
                rel_path = filepath

            if not should_include_file(rel_path, include_patterns, exclude_patterns):
                continue

            try:
                file_size = os.path.getsize(filepath)
                if file_size > max_file_size:
                    continue

                if is_binary_file(filepath):
                    continue

                with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
                    content = f.read()

                files[rel_path] = content

            except Exception as e:
                print(f"Warning: Could not read {filepath}: {e}", file=sys.stderr)

    return {"files": files}


def crawl_github_repo(
    repo_url: str,
    token: Optional[str],
    include_patterns: list[str],
    exclude_patterns: list[str],
    max_file_size: int,
    use_relative_paths: bool = True,
) -> dict:
    """Crawl a GitHub repository and return file contents."""
    if not HAS_REQUESTS:
        print("Error: 'requests' library required for GitHub crawling. Install with: pip install requests", file=sys.stderr)
        sys.exit(1)

    parsed = urlparse(repo_url)
    path_parts = parsed.path.strip('/').split('/')
    if len(path_parts) < 2:
        print(f"Error: Invalid GitHub URL: {repo_url}", file=sys.stderr)
        sys.exit(1)

    owner = path_parts[0]
    repo = path_parts[1].replace('.git', '')

    headers = {'Accept': 'application/vnd.github.v3+json'}
    if token:
        headers['Authorization'] = f'token {token}'

    api_url = f'https://api.github.com/repos/{owner}/{repo}/git/trees/HEAD?recursive=1'

    try:
        response = requests.get(api_url, headers=headers, timeout=30)
        response.raise_for_status()
        tree_data = response.json()
    except Exception as e:
        print(f"Error fetching repository tree: {e}", file=sys.stderr)
        sys.exit(1)

    files = {}

    for item in tree_data.get('tree', []):
        if item['type'] != 'blob':
            continue

        filepath = item['path']

        if not should_include_file(filepath, include_patterns, exclude_patterns):
            continue

        if item.get('size', 0) > max_file_size:
            continue

        try:
            file_url = f'https://api.github.com/repos/{owner}/{repo}/contents/{filepath}'
            file_response = requests.get(file_url, headers=headers, timeout=30)
            file_response.raise_for_status()
            file_data = file_response.json()

            if file_data.get('encoding') == 'base64':
                import base64
                content = base64.b64decode(file_data['content']).decode('utf-8', errors='ignore')
            else:
                content = file_data.get('content', '')

            files[filepath] = content
            print(f"Fetched: {filepath}", file=sys.stderr)

        except Exception as e:
            print(f"Warning: Could not fetch {filepath}: {e}", file=sys.stderr)

    return {"files": files}


def main():
    parser = argparse.ArgumentParser(
        description='Crawl a codebase and output file contents as JSON'
    )

    source_group = parser.add_mutually_exclusive_group(required=True)
    source_group.add_argument('--dir', '-d', help='Local directory to crawl')
    source_group.add_argument('--repo', '-r', help='GitHub repository URL')

    parser.add_argument(
        '--include', '-i',
        nargs='+',
        default=['*.py'],
        help='File patterns to include (default: *.py)'
    )
    parser.add_argument(
        '--exclude', '-e',
        nargs='+',
        default=['*test*', '*spec*', '__pycache__/*', 'node_modules/*', '.git/*', 'venv/*', 'dist/*', 'build/*'],
        help='File patterns to exclude'
    )
    parser.add_argument(
        '--max-size',
        type=int,
        default=100000,
        help='Maximum file size in bytes (default: 100000)'
    )
    parser.add_argument(
        '--output', '-o',
        help='Output file (default: stdout)'
    )
    parser.add_argument(
        '--token', '-t',
        help='GitHub token for private repos (or set GITHUB_TOKEN env var)'
    )
    parser.add_argument(
        '--project-name', '-n',
        help='Project name (default: derived from path/URL)'
    )

    args = parser.parse_args()

    if args.dir:
        project_name = args.project_name or os.path.basename(os.path.abspath(args.dir))
        result = crawl_local_directory(
            args.dir,
            args.include,
            args.exclude,
            args.max_size,
        )
    else:
        token = args.token or os.environ.get('GITHUB_TOKEN')
        parsed = urlparse(args.repo)
        project_name = args.project_name or parsed.path.strip('/').split('/')[-1].replace('.git', '')
        result = crawl_github_repo(
            args.repo,
            token,
            args.include,
            args.exclude,
            args.max_size,
        )

    files_list = [
        {"index": i, "path": path, "content": content}
        for i, (path, content) in enumerate(sorted(result["files"].items()))
    ]

    output = {
        "project_name": project_name,
        "file_count": len(files_list),
        "files": files_list,
    }

    json_output = json.dumps(output, indent=2, ensure_ascii=False)

    if args.output:
        with open(args.output, 'w', encoding='utf-8') as f:
            f.write(json_output)
        print(f"Wrote {len(files_list)} files to {args.output}", file=sys.stderr)
    else:
        print(json_output)


if __name__ == '__main__':
    main()
