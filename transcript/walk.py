"""The transcript as a walk a judge can click through: transcript/site/, written by generate.py.

Nothing here runs a room or reads a chain. generate.py hands over the same forge results and the
same blocks of lines it writes into the .md pages, and this file lays them out as rooms: the
plaque from the exhibit's README, the spec on the row, the code the finding points at, the hunt,
the two doors, and the way on. The plaques, specs, findings and code are read from the commit
the pages are made from, so the site says nothing the repository does not.

The four clicks: enter Room 1, "Show me", a door, walk on. Without JavaScript every door is
open and the walk still reads top to bottom.
"""
import hashlib
import html
import json
import re

REPO = "https://github.com/Aui76/two-doors"
BLOB = REPO + "/blob/main/"
TREE = REPO + "/tree/main/"

# What each page shows beside its forge output. The numbers in "ground", "one" and "two" are
# the indexes of the page's sections in generate.PAGES: where the room stands, door one (the
# attack, run on the fork) and door two (the finding, filed in review).
ROOMS = {
    "room-1": {"plaque": "exhibits/beanstalk-2022-04/review/README.md",
               "spec": "exhibits/beanstalk-2022-04/spec/governance-v0.json",
               "finding": "exhibits/beanstalk-2022-04/review/finding.json",
               "source": "exhibits/beanstalk-2022-04",
               "ground": [0], "one": [1], "two": [2]},
    "room-2": {"plaque": "exhibits/bybit-2025-02/README.md",
               "spec": "exhibits/bybit-2025-02/spec/safe-v1.1.1.json",
               "source": "exhibits/bybit-2025-02",
               "ground": [0]},
    "room-3": {"plaque": "exhibits/balancer-2025-11/review/README.md",
               "spec": "exhibits/balancer-2025-11/spec/swap-rounding-v0.json",
               "finding": "exhibits/balancer-2025-11/review/finding.json",
               "source": "exhibits/balancer-2025-11",
               "ground": [0], "one": [1, 2], "two": [3]},
    "exit": {"plaque": "exhibits/exit/README.md", "source": "exhibits/exit", "ground": [0]},
    "record": {"plaque": "exhibits/beanstalk-2022-04/verdict/README.md",
               "source": "exhibits/beanstalk-2022-04", "ground": [0, 1]},
}
SHORT = {"room-1": "Room 1", "room-2": "Room 2", "room-3": "Room 3", "exit": "The exit", "record": "On file"}

CSS = """:root {
  color-scheme: dark;
  --bg: #0d0f12; --fg: #d4d7dd; --muted: #7d8590; --rule: #262b33; --card: #12151a;
  --code-bg: #080a0d; --accent: #4fc1d9; --accent-fg: #0d0f12; --ok: #3fd07a; --bad: #f2584f;
  --warn: #e6c26a; --door: #12151a;
  --mono: "JetBrains Mono", ui-monospace, "Cascadia Mono", "SF Mono", Menlo, Consolas, monospace;
}
* { box-sizing: border-box; }
html { -webkit-text-size-adjust: 100%; }
body { margin: 0; background: var(--bg); color: var(--fg); font: 15px/1.65 var(--mono); }
main, header .bar, footer .bar { max-width: 50rem; margin: 0 auto; padding: 0 16px; }
header { border-bottom: 1px solid var(--rule); background: var(--code-bg); }
header .bar { display: flex; flex-wrap: wrap; gap: .25rem 1rem; align-items: baseline; padding-top: .7rem; padding-bottom: .7rem; }
header .home { font-weight: 700; color: var(--ok); text-decoration: none; margin-right: auto; }
header .home::before { content: "$ "; color: var(--muted); }
header nav a { color: var(--muted); text-decoration: none; font-size: .85rem; }
header nav a:hover { color: var(--fg); }
header nav a[aria-current] { color: var(--accent); font-weight: 700; }
header nav { display: flex; flex-wrap: wrap; gap: .2rem .9rem; }
h1, h2, h3, h4 { font-family: var(--mono); line-height: 1.3; color: #f2f4f7; }
h1 { font-size: 1.6rem; margin: 2rem 0 1rem; }
h1::before { content: "$ "; color: var(--ok); }
h2 { font-size: 1.15rem; margin: 2.4rem 0 .6rem; padding-top: .8rem; border-top: 1px dashed var(--rule); }
h2::before { content: "# "; color: var(--muted); }
h3 { font-size: 1rem; margin: 1.6rem 0 .4rem; color: var(--warn); }
h4 { font-size: .9rem; margin: 1.4rem 0 .3rem; font-weight: 600; }
a { color: var(--accent); text-underline-offset: 2px; }
code { font: .92em/1.4 var(--mono); background: var(--code-bg); color: #e8eaee; padding: .05em .3em; border-radius: 3px; overflow-wrap: anywhere; }
h4 a code, h4 code { background: none; padding: 0; color: var(--accent); }
pre { background: var(--code-bg); border: 1px solid var(--rule); padding: .8rem 1rem; border-radius: 4px; overflow-x: auto; font-size: .8rem; line-height: 1.5; color: #c9cdd4; }
pre code { background: none; padding: 0; overflow-wrap: normal; color: inherit; }
blockquote { margin: 1rem 0; padding: .1rem 1rem; border-left: 2px solid var(--rule); color: var(--muted); }
table { border-collapse: collapse; font-size: .8rem; display: block; overflow-x: auto; }
th, td { border: 1px solid var(--rule); padding: .3rem .5rem; text-align: left; vertical-align: top; }
th { color: var(--warn); }
.lede { font-size: 1rem; }
.muted, .src { color: var(--muted); font-size: .85rem; }
.plaque { background: var(--card); border: 1px solid var(--rule); border-radius: 4px; padding: .4rem 1.2rem; }
.spec ol { padding-left: 1.6rem; }
.spec li { margin: .5rem 0; }
.spec li::marker { color: var(--muted); }
.spec li code.id { font-size: .85em; }
.excerpt pre { counter-reset: none; }
.ln { color: #4a525d; user-select: none; }
.test { margin: .5rem 0 .9rem; }
.test p { margin: .2rem 0; }
.test p code { background: none; padding: 0; }
.pass { color: var(--ok); font-weight: 700; }
.fail { color: var(--bad); font-weight: 700; }
details { background: var(--card); border: 1px solid var(--rule); border-radius: 4px; padding: .6rem 1rem; margin: 1rem 0; }
details > summary { cursor: pointer; font-weight: 700; }
details.hunt > summary { color: var(--warn); }
details.hunt blockquote { color: var(--fg); border-left-color: var(--warn); }
.btn { display: inline-block; background: transparent; color: var(--ok); border: 1px solid var(--ok); border-radius: 4px;
  padding: .6rem 1.1rem; font: 700 .95rem/1.2 var(--mono); text-decoration: none; cursor: pointer; }
.btn::before { content: "> "; }
.btn:hover { background: var(--ok); color: var(--bg); }
.btn:focus-visible, details > summary:focus-visible, .doors button:focus-visible { outline: 2px solid var(--accent); outline-offset: 2px; }
.doors { display: grid; grid-template-columns: 1fr 1fr; gap: .8rem; margin: 1rem 0; }
@media (max-width: 560px) { .doors { grid-template-columns: 1fr; } }
.doors button { text-align: left; background: var(--door); color: var(--fg); border: 1px solid var(--rule);
  border-radius: 4px; padding: .9rem 1rem; font: inherit; cursor: pointer; }
.doors button:hover { border-color: var(--muted); }
.doors button strong { display: block; font-size: 1rem; color: var(--accent); }
.doors button[aria-pressed="true"] { border-color: var(--ok); box-shadow: inset 0 0 0 1px var(--ok); }
.doors button[aria-pressed="true"] strong { color: var(--ok); }
.door { border-left: 2px solid var(--ok); padding-left: 1rem; margin: 1.5rem 0; }
.js .door:not(.open) { display: none; }
dl.filed dt { font-weight: 700; margin-top: .6rem; color: var(--warn); }
dl.filed dd { margin: 0; }
.next { margin: 2.5rem 0 1rem; }
footer { border-top: 1px solid var(--rule); margin-top: 3rem; background: var(--code-bg); }
footer .bar { padding-top: 1rem; padding-bottom: 2rem; font-size: .8rem; color: var(--muted); }
footer strong { color: var(--ok); }
footer pre { font-size: .76rem; }
"""

JS = """document.addEventListener("click", function (e) {
  var b = e.target.closest("[data-door]");
  if (!b) return;
  document.querySelectorAll(".door").forEach(function (d) { d.classList.toggle("open", d.id === b.dataset.door); });
  document.querySelectorAll("[data-door]").forEach(function (x) { x.setAttribute("aria-pressed", String(x === b)); });
  document.getElementById(b.dataset.door).scrollIntoView({ behavior: "smooth", block: "start" });
});
"""


def esc(s):
    return html.escape(str(s), quote=True)


def link_to(url, base):
    """Where a markdown link goes on the site: other transcript pages stay here, files go to GitHub."""
    if re.match(r"[a-z]+:", url) or url.startswith("#"):
        return url
    if base == "transcript" and url.endswith(".md"):
        return "index.html" if url == "README.md" else url[:-3] + ".html"
    parts = [p for p in (base + "/" + url).split("/") if p and p != "."]
    out = []
    for p in parts:
        if p == "..":
            out.pop()
        else:
            out.append(p)
    path = "/".join(out)
    return (TREE if path.endswith("/") or "." not in out[-1] else BLOB) + path


def inline(text, base):
    pieces = re.split(r"(`[^`]*`)", text)
    out = []
    for p in pieces:
        if p.startswith("`") and p.endswith("`") and len(p) > 1:
            out.append("<code>%s</code>" % esc(p[1:-1]))
            continue
        p = esc(p)
        p = re.sub(r"\*\*(.+?)\*\*", r"<strong>\1</strong>", p)
        p = re.sub(r"\[([^\]]+)\]\(([^)\s]+)\)",
                   lambda m: '<a href="%s">%s</a>' % (esc(link_to(html.unescape(m.group(2)), base)), m.group(1)), p)
        out.append(p)
    return "".join(out)


def markdown(lines, base):
    """The few shapes the plaques and pages use: headings, fences, tables, lists, quotes, paragraphs.
    An HTML comment line passes through untouched, which keeps the stamp and live markers."""
    out, para, i = [], [], 0

    def flush():
        if para:
            out.append("<p>%s</p>" % inline(" ".join(para), base))
            del para[:]

    while i < len(lines):
        line = lines[i]
        s = line.strip()
        if s.startswith("<!--") and s.endswith("-->"):
            flush()
            if "SPDX" not in s:
                out.append(s)
            i += 1
        elif s.startswith("```"):
            flush()
            lang = s[3:].strip() or "text"
            body = []
            i += 1
            while i < len(lines) and not lines[i].strip().startswith("```"):
                body.append(lines[i])
                i += 1
            i += 1
            out.append('<pre><code class="language-%s">%s</code></pre>' % (esc(lang), esc("\n".join(body))))
        elif re.match(r"#{1,4} ", s):
            flush()
            n = len(s.split(" ")[0])
            out.append("<h%d>%s</h%d>" % (n + 1 if n < 4 else 4, inline(s[n + 1:], base), n + 1 if n < 4 else 4))
            i += 1
        elif s.startswith("|"):
            flush()
            rows = []
            while i < len(lines) and lines[i].strip().startswith("|"):
                rows.append([c.strip() for c in lines[i].strip().strip("|").split("|")])
                i += 1
            head, body = rows[0], [r for r in rows[1:] if not all(re.match(r"^:?-+:?$", c) for c in r)]
            out.append("<table><thead><tr>%s</tr></thead><tbody>%s</tbody></table>" % (
                "".join("<th>%s</th>" % inline(c, base) for c in head),
                "".join("<tr>%s</tr>" % "".join("<td>%s</td>" % inline(c, base) for c in r) for r in body)))
        elif s.startswith("- "):
            flush()
            items = []
            while i < len(lines) and lines[i].strip().startswith("- "):
                items.append(lines[i].strip()[2:])
                i += 1
            out.append("<ul>%s</ul>" % "".join("<li>%s</li>" % inline(t, base) for t in items))
        elif s.startswith(">"):
            flush()
            quote = []
            while i < len(lines) and lines[i].strip().startswith(">"):
                quote.append(lines[i].strip()[1:].strip())
                i += 1
            out.append("<blockquote><p>%s</p></blockquote>" % inline(" ".join(quote), base))
        elif not s:
            flush()
            i += 1
        else:
            para.append(s)
            i += 1
    flush()
    return out


def intro(root, rel):
    """A README up to its first ## heading, without its title: the plaque on the wall."""
    lines = (root / rel).read_text(encoding="utf-8").splitlines()
    cut = next((n for n, l in enumerate(lines) if l.startswith("## ")), len(lines))
    body = [l for l in lines[:cut] if not l.startswith("# ")]
    return markdown(body, rel.rsplit("/", 1)[0] if "/" in rel else "")


def test_html(results, files, base):
    out = []
    for path in files:
        out.append('<h4><a href="%s"><code>%s</code></a></h4>' % (esc(BLOB + path), esc(path)))
        for contract, name, res in results[path]:
            ok = res["status"] == "Success"
            out.append('<div class="test"><p><span class="%s">%s</span> <code>%s.%s</code>%s</p>' % (
                "pass" if ok else "fail", "[PASS]" if ok else "[FAIL]", esc(contract), esc(name),
                "" if ok else ": " + esc(res.get("reason"))))
            logs = res.get("decoded_logs") or []
            if logs:
                out.append("<pre><code>%s</code></pre>" % esc("\n".join(logs)))
            else:
                out.append('<p class="muted">It prints nothing; it asserts.</p>')
            out.append("</div>")
    return out


def section_html(sections, idx, results, level=3):
    out = []
    for i in idx:
        heading, files, extra = sections[i]
        out.append("<h%d>%s</h%d>" % (level, inline(heading, "transcript"), level))
        out += test_html(results, files, "transcript")
        out += markdown(extra, "transcript")
    return out


def spec_html(root, rel, seat):
    spec = json.loads((root / rel).read_text(encoding="utf-8"))
    t = spec["target"]
    out = ['<div class="spec">',
           "<p>%s <strong>%s</strong>, <code>%s</code> on chain %s at block %s, runtime codehash <code>%s</code>.</p>"
           % ("The row names" if seat else "The check reads", esc(t["name"]), esc(t["address"]), esc(t["chainId"]), "{:,}".format(t["block"]), esc(t["codehash"])),
           '<p>The spec%s, <a href="%s"><code>%s</code></a>: %d invariants, each with the line it was read from.</p>'
           % (" on the row" if seat else "", esc(BLOB + rel), esc(rel.rsplit("/", 1)[1]), len(spec["invariants"])),
           "<ol>"]
    for inv in spec["invariants"]:
        out.append('<li>%s<br><span class="src"><code class="id">%s</code> · %s</span></li>'
                   % (esc(inv["statement"]), esc(inv["id"]), esc(inv["_source"])))
    out += ["</ol>", "</div>"]
    return out


def missing(text):
    """The finding's _missing_from opens with the spec file it is missing from."""
    m = re.match(r"(\S+\.json)\. (.*)", text, flags=re.S)
    return ("It is missing from <code>%s</code>. %s" % (esc(m.group(1)), esc(m.group(2)))) if m else esc(text)


def excerpts(root, location):
    """The lines the finding's location names, read from the vendored specimens."""
    out = []
    for m in re.finditer(r"(specimens/[\w\-./]+\.sol) lines? (\d+)(?:-(\d+))?", location):
        rel, a = m.group(1), int(m.group(2))
        b = int(m.group(3) or a)
        data = (root / rel).read_bytes()
        lines = data.decode("utf-8").split("\n")
        width = len(str(b))
        body = "\n".join('<span class="ln">%s</span>  %s' % (str(n).rjust(width), esc(lines[n - 1].rstrip("\r")))
                         for n in range(a, b + 1))
        out.append('<div class="excerpt"><h4><a href="%s#L%d-L%d"><code>%s</code></a> lines %d to %d</h4>'
                   % (esc(BLOB + rel), a, b, esc(rel), a, b))
        out.append("<pre><code>%s</code></pre>" % body)
        out.append('<p class="src">The whole file\'s sha256 is <code>0x%s</code>, the one the finding names.</p></div>'
                   % hashlib.sha256(data).hexdigest())
    return out


def page(slug, title, body, stamp, tally):
    nav = "".join('<a href="%s.html"%s>%s</a>' % (s, ' aria-current="page"' if s == slug else "", esc(SHORT[s]))
                  for s in SHORT)
    return "\n".join([
        "<!doctype html>",
        '<html lang="en">',
        "<head>",
        '<meta charset="utf-8">',
        '<meta name="viewport" content="width=device-width, initial-scale=1">',
        "<title>%s</title>" % esc(title if slug == "index" else title + " · Two Doors"),
        '<meta name="description" content="A museum where you stand inside a real hack at the block before it happened and find the loophole yourself.">',
        '<link rel="preconnect" href="https://fonts.googleapis.com">',
        '<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>',
        '<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@400;600;700&display=swap">',
        '<link rel="stylesheet" href="style.css">',
        '<script>document.documentElement.className = "js";</script>',
        '<script src="walk.js" defer></script>',
        "</head>",
        "<body>",
        '<header><div class="bar"><a class="home" href="index.html">Two Doors</a><nav>%s</nav></div></header>' % nav,
        "<main>"] + body + [
        "</main>",
        '<footer><div class="bar">',
        "<p><strong>%d passed, %d failed.</strong> Every line of output on this page is what <code>forge test --json -vv</code> "
        "returned. The plaques, specs, findings and code are read from the same commit.</p>" % tuple(tally)] + stamp + [
        "<p>Run it yourself:</p>",
        "<pre><code>git clone %s\ncd two-doors\npython transcript/generate.py --check</code></pre>" % REPO,
        '<p><a href="%s">The repository</a></p>' % REPO,
        "</div></footer>",
        "</body>",
        "</html>"])


def room(slug, title, sections, results, root, nxt):
    r = ROOMS[slug]
    body = ["<h1>%s</h1>" % esc(title), '<div class="plaque">'] + intro(root, r["plaque"]) + ["</div>"]
    if "spec" in r:
        body += ["<h2>%s</h2>" % ("The row in front of you" if "finding" in r else "The spec the check runs")]
        body += spec_html(root, r["spec"], "finding" in r)
    if "finding" in r:
        f = json.loads((root / r["finding"]).read_text(encoding="utf-8"))
        inv = f["invariant"]
        body += ["<h2>The code the spec points at</h2>",
                 "<p>The code does what each invariant says. Read it beside the list above. "
                 "What does the spec never say?</p>"]
        body += excerpts(root, f["location"])
        body += ['<details class="hunt"><summary>Show me</summary>',
                 "<p>The invariant the spec is missing:</p>",
                 "<blockquote><p>%s</p></blockquote>" % esc(inv["statement"]),
                 "<p>%s</p>" % missing(inv["_missing_from"]),
                 "</details>",
                 "<h2>Choose a door</h2>",
                 '<div class="doors">',
                 '<button type="button" data-door="door-one" aria-pressed="false"><strong>Door one</strong>'
                 "The attack the gap allows, run on the fork.</button>",
                 '<button type="button" data-door="door-two" aria-pressed="false"><strong>Door two</strong>'
                 "File the finding in review, and be paid for it.</button>",
                 "</div>",
                 '<section class="door" id="door-one"><h2>Door one</h2>']
        body += section_html(sections, r["one"], results)
        body += ["</section>", '<section class="door" id="door-two"><h2>Door two</h2>',
                 "<h3>What you file</h3>", '<dl class="filed">',
                 "<dt>The invariant</dt><dd><code>%s</code>: %s</dd>" % (esc(inv["id"]), esc(inv["statement"])),
                 "<dt>Where it fails</dt><dd>%s</dd>" % esc(f["location"]),
                 "<dt>The witness</dt><dd>%s</dd>" % esc(f["witness"]),
                 "<dt>The context</dt><dd>%s</dd>" % esc(f["context"]),
                 "</dl>",
                 '<p class="src">From <a href="%s"><code>%s</code></a>. The cell receives only the keccak256 of each '
                 "string; the test below reads them from this file.</p>" % (esc(BLOB + r["finding"]), esc(r["finding"]))]
        body += section_html(sections, r["two"], results)
        body += ["</section>"]
        body += ['<details><summary>Where the room stands</summary>'] + section_html(sections, r["ground"], results) + ["</details>"]
    else:
        body += ["<h2>What the room prints</h2>"] + section_html(sections, r["ground"], results)
    body.append('<p class="src">This room\'s source: <a href="%s"><code>%s/</code></a></p>'
                % (esc(TREE + r["source"]), esc(r["source"])))
    if nxt:
        body.append('<p class="next"><a class="btn" href="%s.html">%s</a></p>' % (nxt[0], esc(nxt[1])))
    return body


def front(root, rooms):
    body = ["<h1>Two doors</h1>", '<div class="lede">'] + intro(root, "README.md") + ["</div>",
            '<p class="next"><a class="btn" href="room-1.html">Enter Room 1</a></p>',
            "<h2>The walk</h2>", "<ol>"]
    for slug, title in rooms:
        body.append('<li><a href="%s.html">%s</a></li>' % (slug, esc(title)))
    body += ["</ol>",
             '<p class="muted">The same pages as plain text, with the stamp of the run that wrote them: '
             '<a href="%s">transcript/README.md</a>.</p>' % (BLOB + "transcript/README.md")]
    return body


NEXT = {"room-1": ("room-2", "Walk on to Room 2"), "room-2": ("room-3", "Walk on to Room 3"),
        "room-3": ("exit", "Walk on to the exit"), "exit": ("record", "What stays on file"),
        "record": ("index", "Back to the door")}


def build(layout, results, stamp_md, tally, root):
    """layout is [(slug, title, [(heading, files, extra md lines)])] in walk order; results maps a
    test file to its (contract, name, result) list. Returns {path under transcript/: text}."""
    stamp = markdown(stamp_md, "transcript")
    out = {"site/style.css": CSS, "site/walk.js": JS}
    for slug, title, sections in layout:
        out["site/%s.html" % slug] = page(slug, title, room(slug, title, sections, results, root, NEXT.get(slug)),
                                          stamp, tally) + "\n"
    out["site/index.html"] = page("index", "Two Doors", front(root, [(s, t) for s, t, _ in layout]),
                                  stamp, tally) + "\n"
    return out
