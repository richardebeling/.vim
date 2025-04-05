#!/usr/bin/env python3

import http.client
import json
import re
import sys
import time
import urllib.request
from pathlib import Path


vimrc = Path("vimrc")
GITHUB_TOKEN = ""


def response_for_api_path(
    uri: str, content_type: str = "application/vnd.github+json"
) -> http.client.HTTPResponse:
    request = urllib.request.Request(uri)
    request.add_header("Accept", content_type)
    request.add_header("X-GitHub-Api-Version", "2022-11-28")
    if GITHUB_TOKEN:
        request.add_header("Authorization", f"Bearer {GITHUB_TOKEN}")

    while True:
        try:
            return urllib.request.urlopen(request)
        except urllib.error.HTTPError as e:
            if e.code == 403:  # rate limit exceeded
                sleep_time = max(
                    0.3, int(e.headers["x-ratelimit-reset"]) - time.time() + 0.1
                )
                print(
                    f"Hit rate limit of {e.headers['x-ratelimit-limit']} requests. "
                    + f"Sleeping for {sleep_time:.2f} seconds",
                    file=sys.stderr,
                )
                time.sleep(sleep_time)
                continue
            raise


def get_plugins_with_commits() -> list[tuple[str, str]]:
    PLUG_PATTERN = r"Plug +?'(\S+?/\S+?)',\s*\{[^\}]*?'commit':\s*'([a-fA-F0-9]{40})'"
    matches = re.findall(PLUG_PATTERN, Path("vimrc").read_text(), re.DOTALL)
    return [(match[0], match[1]) for match in matches]


def get_latest_plugin_commit(plugin: str) -> str:
    response = response_for_api_path(
        f"https://api.github.com/repos/{plugin}/commits",
        "application/vnd.github.VERSION.sha",
    ).read()

    return json.loads(response)[0]['sha']


if __name__ == "__main__":
    if not vimrc.exists():
      print("Error: couldn't find vimrc. Exiting...")
      sys.exit(1)

    plugins = get_plugins_with_commits()
    for repo, commit in plugins:
        latest_commit = get_latest_plugin_commit(repo)
        if latest_commit.lower().strip() == commit.lower().strip():
            print(f"Plugin {repo} is up to date")
            continue

        print()
        print(f"Plugin {repo} has new stuff")
        print(
            f"Github diff: https://github.com/{repo}/compare/{commit}..{latest_commit}"
        )
        while (choice := input("Update? (y/n) ").lower()) not in ("y", "n"):
            pass
        if choice == "y":
            old = vimrc.read_text()
            vimrc.write_text(old.replace(commit, latest_commit))
        print()
