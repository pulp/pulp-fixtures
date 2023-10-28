#!/usr/bin/env python3
# coding=utf-8
"""Format urls in PyPI JSON metadata."""
import argparse
import json
import sys

from functools import reduce
from urllib.parse import urljoin
from itertools import chain


def main():
    """Parse arguments, consume stdin, and produce stdout."""
    parser = argparse.ArgumentParser(
        description="Format the URLs in the PyPI JSON metadata."
    )
    parser.add_argument(
        "metadata_path",
        type=argparse.FileType("r"),
        help=(
            """\
            The path to a PyPI JSON metadata file. If -, the file is read from
            stdin.
            """
        ),
    )
    parser.add_argument(
        "base_url",
        type=str,
        help="base_url at which the fixture packages are located",
    )
    args = parser.parse_args()
    try:
        print(format_url(json.load(args.metadata_path), args.base_url))
    finally:
        args.metadata_path.close()


def format_url(metadata, base_url):
    """Format the distribution urls in metadata to point to the distributions
    hosted on base_url"""
    release_urls = metadata.get("releases", {}).values()
    url_urls = [metadata.get("urls", [])]
    for distributions in chain(release_urls, url_urls):
        for distribution in distributions:
            distribution["url"] = reduce(
                urljoin,
                [
                    base_url,
                    "python-pypi/packages/",
                    distribution["filename"],
                ],
            )
    return json.dumps(metadata, indent=4)


if __name__ == "__main__":
    sys.exit(main())
