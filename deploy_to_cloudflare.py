#!/usr/bin/env python3
"""
deploy_to_cloudflare.py  —  boodschappen_grafiek.html → sinisternl.nl/boodschappen
Dubbelklik om te runnen, of: python3 deploy_to_cloudflare.py
"""

import urllib.request, urllib.error, json, os, sys
from pathlib import Path

API_TOKEN = "5e335f7450b5e051f0a43b390dbe1269"
HTML_FILE = "boodschappen_grafiek.html"
BASE      = "https://api.cloudflare.com/client/v4"

def api(method, path, data=None, content_type="application/json", raw_body=None):
    url = BASE + path
    body = raw_body if raw_body else (json.dumps(data).encode() if data else None)
    req  = urllib.request.Request(url, data=body, method=method)
    req.add_header("Authorization", f"Bearer {API_TOKEN}")
    if raw_body is None:
        req.add_header("Content-Type", content_type)
    try:
        with urllib.request.urlopen(req) as r:
            return json.loads(r.read())
    except urllib.error.HTTPError as e:
        return json.loads(e.read())

def get_account_id():
    r = api("GET", "/accounts")
    if not r.get("success"):
        print("❌ Token fout:", r.get("errors"))
        sys.exit(1)
    return r["result"][0]["id"]

def list_projects(account_id):
    r = api("GET", f"/accounts/{account_id}/pages/projects")
    if not r.get("success"):
        print("❌ Kan projecten niet ophalen:", r.get("errors"))
        sys.exit(1)
    return r["result"]

def deploy(account_id, project_name, html_path):
    content = html_path.read_bytes()
    print(f"\n📄 Uploaden naar '{project_name}': {len(content):,} bytes")

    boundary = "----CF7MA4YWxkTrZu0gW"
    body = (
        f"--{boundary}\r\n"
        f'Content-Disposition: form-data; name="manifest"\r\n\r\n'
        '{"/index.html":"' + HTML_FILE + '"}\r\n'
        f"--{boundary}\r\n"
        f'Content-Disposition: form-data; name="/index.html"; filename="index.html"\r\n'
        f"Content-Type: text/html; charset=utf-8\r\n\r\n"
    ).encode("utf-8") + content + f"\r\n--{boundary}--\r\n".encode()

    url  = f"{BASE}/accounts/{account_id}/pages/projects/{project_name}/deployments"
    req  = urllib.request.Request(url, data=body, method="POST")
    req.add_header("Authorization", f"Bearer {API_TOKEN}")
    req.add_header("Content-Type",  f"multipart/form-data; boundary={boundary}")

    try:
        with urllib.request.urlopen(req) as resp:
            result = json.loads(resp.read())
    except urllib.error.HTTPError as e:
        result = json.loads(e.read())

    if result.get("success"):
        dep = result["result"]
        live_url = dep.get("url") or f"https://{project_name}.pages.dev"
        print(f"\n🚀 LIVE!  {live_url}")
        print(f"   sinisternl.nl/boodschappen wordt binnen ~30 sec bijgewerkt")
        print(f"   Deployment ID: {dep.get('id','?')}")
    else:
        print("❌ Deploy mislukt:", result.get("errors"))
        sys.exit(1)

if __name__ == "__main__":
    print("=" * 55)
    print("  Boodschappen → sinisternl.nl/boodschappen  Deploy")
    print("=" * 55)

    html_path = Path(__file__).parent / HTML_FILE
    if not html_path.exists():
        print(f"\n❌ Bestand niet gevonden: {html_path}")
        print(f"   Zet '{HTML_FILE}' in dezelfde map als dit script.")
        input("\nDruk Enter om te sluiten...")
        sys.exit(1)

    print("\n🔑 Account ophalen...")
    account_id = get_account_id()
    print(f"✅ Account ID: {account_id[:8]}...")

    projects = list_projects(account_id)
    if not projects:
        print("❌ Geen Pages projecten gevonden op dit account.")
        sys.exit(1)

    print(f"\n📋 Gevonden Pages projecten ({len(projects)}):")
    for i, p in enumerate(projects):
        domains = [d["name"] for d in p.get("domains", [])]
        dom_str = f"  →  {', '.join(domains)}" if domains else ""
        print(f"  [{i+1}] {p['name']}{dom_str}")

    # Auto-select project linked to sinisternl.nl
    target = None
    for p in projects:
        domains = [d["name"] for d in p.get("domains", [])]
        if any("sinisternl" in d or "boodschappen" in d for d in domains):
            target = p
            break
    if not target and len(projects) == 1:
        target = projects[0]

    if not target:
        print(f"\nWelk project is sinisternl.nl/boodschappen? (voer nummer in)")
        choice = int(input("Nummer: ")) - 1
        target = projects[choice]

    print(f"\n✅ Deployen naar: '{target['name']}'")
    deploy(account_id, target["name"], html_path)

    print("\n✅ Klaar!")
    input("\nDruk Enter om te sluiten...")
