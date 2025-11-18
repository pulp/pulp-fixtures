#!/usr/bin/env python3
# coding=utf-8
# pylint: skip-file

import argparse
import json
import requests
from jinja2 import Template
from pathlib import Path
from urllib.parse import urljoin
from packaging.utils import canonicalize_name
from pypi_simple import parse_filename


simple_index_template = """<!DOCTYPE html>
<html>
  <head>
    <title>Simple Index</title>
    <meta name="pypi:repository-version" content="{{ repository_version }}">
  </head>
  <body>
    {% for name, canonical_name in projects %}
      <a href="{{ canonical_name }}/">{{ name }}</a><br/>
    {% endfor %}
  </body>
</html>
"""

simple_detail_template = """<!DOCTYPE html>
<html>
  <head>
    <title>Links for {{ project.name }}</title>
    <meta name="pypi:repository-version" content="{{ repository_version }}">
    {% if project.tracks -%}
      {%- for url in project.tracks %}
    <meta name="pypi:tracks" content="{{ url }}">
      {%- endfor -%}
    {%- endif %}
    {% if project['alternate-locations'] -%}
      {%- for url in project['alternate-locations'] %}
    <meta name="pypi:alternate-locations" content="{{ url }}">
      {%- endfor -%}
    {%- endif %}
    {% if project['project-status'] -%}
    <meta name="pypi:status" content="{{ project['project-status'].status }}">
    {% if project['project-status'].reason is defined -%}
    <meta name="pypi:status-reason" content="{{ project['project-status'].reason }}">
    {% endif -%}
    {%- endif %}
  </head>
  <body>
    <h1>Links for {{ project.name }}</h1>
    {% for pkg in project.files %}
      <a href="{{ pkg.url }}#sha256={{ pkg.hashes.sha256 }}" rel="internal" {% if pkg['requires-python'] -%}
      data-requires-python="{{ pkg['requires-python'] }}" 
      {%- endif %} {% if pkg.yanked -%}
      data-yanked="{{ pkg.yanked }}"
      {%- endif %} {% if pkg['core-metadata'] -%}
      data-dist-info-metadata="sha256={{ pkg['core-metadata'].sha256 }}" data-core-metadata="sha256={{ pkg['core-metadata'].sha256 }}"
      {%- endif %} {% if pkg.provenance -%}
      data-provenance="{{ pkg.provenance }}"
      {%- endif -%}
      >{{ pkg.filename }}</a><br/>
    {% endfor %}
  </body>
</html>
"""

simple_index_template = Template(simple_index_template)
simple_detail_template = Template(simple_detail_template)

def simple_index_json(projects, repository_version="1.4"):
    return {
        "meta": {"api-version": repository_version, "_last-serial": 1000000000},
        "projects": [{"name": canonicalize_name(p), "_last-serial": 1000000000} for p in projects],
    }

def download(s, url, dest):
    r = s.get(url)
    r.raise_for_status()
    write_file(dest, r.content)

def write_file(path, content):
    path = Path(path)
    path.parent.mkdir(parents=True, exist_ok=True)
    mode = "wb" if isinstance(content, bytes) else "w"
    with open(path, mode) as f:
        if isinstance(content, (dict, list)):
            json.dump(content, f)
        else:
            f.write(content)

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("output_dir", type=str)
    parser.add_argument("base_url", type=str)
    parser.add_argument("projects_file", type=str)
    args = parser.parse_args()
    output_dir = Path(args.output_dir)
    base_url = args.base_url.rstrip("/") + "/"

    with open(args.projects_file, "r") as f:
        LOADED_PROJECTS = json.load(f)

    project_pages = {}
    with requests.Session() as s:
        s.headers.update({"User-Agent": "fixtures.pulpproject.org/gen-pypi-repo.py"})
        for project, releases in LOADED_PROJECTS["projects"].items():
            r = s.get(f"https://pypi.org/simple/{project}/", headers={"Accept": "application/vnd.pypi.simple.v1+json"})
            r.raise_for_status()
            page = r.json()
            page["files"] = [f for f in page["files"] if f["filename"] in releases]
            page["versions"] = list(set([parse_filename(r)[1] for r in releases]))
            if p_metadata := LOADED_PROJECTS["project_metadata"].get(project):
                page.update(p_metadata)

            project_pages[project] = page
        # Download the project files
        for project, page in project_pages.items():
            for release in page["files"]:
                file = f"packages/{release["filename"]}"
                metadata_file = f"{file}.metadata"
                provenance_file = f"{file}.provenance.json"
                download(s, release["url"], output_dir / file)
                if release.get("core-metadata"):
                    download(s, f"{release['url']}.metadata", output_dir / metadata_file)
                if release.get("provenance"):
                    download(s, release["provenance"], output_dir / provenance_file)
                # Update the page's urls for the later simple generation
                release["url"] = urljoin(base_url, file)
                if release.get("provenance"):
                    release["provenance"] = urljoin(base_url, provenance_file)
        # Generate the simple index
        simple_index_file = output_dir / "simple" / "index.html"
        project_tuples = [(p, canonicalize_name(p)) for p in project_pages.keys()]
        write_file(simple_index_file, simple_index_template.render(projects=project_tuples, repository_version="1.4"))
        write_file(f"{output_dir}/simple/index.json", simple_index_json(project_pages.keys()))
        for project, page in project_pages.items():
            canonical_name = canonicalize_name(project)
            rendered_page = simple_detail_template.render(project=page, repository_version="1.4")
            write_file(f"{output_dir}/simple/{project}/index.html", rendered_page)
            write_file(f"{output_dir}/simple/{project}/index.json", page)
            if canonical_name != project:
                write_file(f"{output_dir}/simple/{canonical_name}/index.html", rendered_page)
                write_file(f"{output_dir}/simple/{canonical_name}/index.json", page)
        # Generate the pypi json API pages
        packages_url = urljoin(base_url, "packages/")
        pypi_dir = output_dir / "pypi"
        for project, page in project_pages.items():
            canonical_name = canonicalize_name(project)
            releases = LOADED_PROJECTS["projects"][project]
            project_jsons = {}
            for version in page["versions"]:
                r = s.get(f"https://pypi.org/pypi/{project}/{version}/json")
                r.raise_for_status()
                version_page = r.json()
                version_page["urls"] = [
                    {**u, "url": urljoin(packages_url, u["filename"])} for u in version_page["urls"] if u["filename"] in releases
                ]
                project_jsons[version] = version_page
                write_file(f"{pypi_dir}/{project}/{version}/json/index.json", version_page)
                if canonical_name != project:
                    write_file(f"{pypi_dir}/{canonical_name}/{version}/json/index.json", version_page)
            # Generate the latest-json page
            if project in LOADED_PROJECTS["latest_versions"]:
                latest_json_page = project_jsons[LOADED_PROJECTS["latest_versions"][project]]
                latest_json_page["releases"] = {k: v["urls"] for k, v in project_jsons.items()}
                write_file(f"{pypi_dir}/{project}/json/index.json", latest_json_page)
                if canonical_name != project:
                    write_file(f"{pypi_dir}/{canonical_name}/json/index.json", latest_json_page)

if __name__ == "__main__":
    main()
