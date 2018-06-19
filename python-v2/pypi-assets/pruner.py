#!/usr/bin/env python3
# coding=utf-8
"""Prune PyPI JSON metadata."""
import argparse
import copy
import json


def main():
    """Parse arguments, consume stdin, and produce stdout."""
    parser = argparse.ArgumentParser(description='Prune PyPI JSON metadata.')
    parser.add_argument(
        'metadata_path',
        type=argparse.FileType('r'),
        help=('''\
            The path to a PyPI JSON metadata file. If -, the file is read from
            stdin.
            '''),
    )
    parser.add_argument(
        'distributions',
        type=json.loads,
        help='A JSON list of filenames to search for and keep in the metadata.'
    )
    args = parser.parse_args()
    try:
        print(prune_metadata(json.load(args.metadata_path), args.distributions))
    finally:
        args.metadata_path.close()

def prune_metadata(old_metadata, available_distributions):
    """Cut unwanted values out of the JSON metadata at ``metadata_path``."""
    # release: e.g. "1.0.1"
    # distributions: e.g. [], or [{egg info}, {wheel info}]
    new_metadata = copy.deepcopy(old_metadata)
    for release, distributions in old_metadata['releases'].items():
        for distribution in distributions:
            if distribution['filename'] not in available_distributions:
                new_metadata['releases'][release].remove(distribution)
        if new_metadata['releases'][release] == []:
            del new_metadata['releases'][release]
    return json.dumps(new_metadata, indent=4)


if __name__ == "__main__":
    exit(main())
