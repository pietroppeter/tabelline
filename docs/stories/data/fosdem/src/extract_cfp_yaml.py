"""Read every version of content/devrooms-cfp.yaml in FOSDEM's archived website repo
(github.com/FOSDEM/website, 2012-2019 CfP seasons, so editions 2013-2020).

Usage: python3 -I extract_cfp_yaml.py <website git clone> <stage dir>
For each edition (a commit from August on belongs to the next year's edition), keeps the
last version of the file and writes one row per devroom: edition, day, devroom,
announcement URL, deadline, and the date the devroom first appeared in the file.
"""
import csv, os, re, subprocess, sys

repo, out = sys.argv[1], sys.argv[2]
path = "content/devrooms-cfp.yaml"
log = subprocess.run(["git", "-C", repo, "log", "--reverse", "--format=%H %ad", "--date=short", "--", path],
                     capture_output=True, text=True, check=True).stdout.split("\n")

def parse(text):
    day, name, rows, cur = "", "", [], None
    if "\ndeadlines:" in text:  # 2012 layout: devroom -> ann (short ids), deadline, days
        for line in text.splitlines():
            m = re.match(r"^  (?! )['\"]?(.+?)['\"]?:\s*$", line)
            if m:
                cur = {"day": "", "devroom": m.group(1).strip(), "ann": "", "deadline": ""}
                rows.append(cur); continue
            m = re.match(r"^\s+(ann|deadline|days):\s*(.*?)\s*$", line)
            n = re.match(r"^\s+-\s*(\S+)", line)
            if cur is None:
                continue
            if m:
                k = "day" if m.group(1) == "days" else m.group(1)
                cur[k] = m.group(2).strip("'\" ")
            elif n and not cur["ann"]:
                cur["ann"] = n.group(1)
        for r in rows:
            if re.match(r"^\d{4}-\w+/\d+$", r["ann"]):
                r["ann"] = f"https://lists.fosdem.org/pipermail/fosdem/{r['ann']}.html"
        return rows
    for line in text.splitlines():
        m = re.match(r"^  (\w+):\s*$", line)
        if m and m.group(1) in ("both", "saturday", "sunday"):
            day = m.group(1); continue
        m = re.match(r"^    (?! )['\"]?(.+?)['\"]?:\s*$", line)
        if m and day and m.group(1) not in ("ann", "deadline"):  # some versions lost an indent
            cur = {"day": day, "devroom": m.group(1).strip(), "ann": "", "deadline": ""}
            rows.append(cur); continue
        m = re.match(r"^\s+(ann|deadline):\s*(.*?)\s*$", line)
        if m and cur is not None:
            cur[m.group(1)] = m.group(2).strip("'\" ")
    return rows

editions, first_seen = {}, {}
for line in log:
    if not line.strip():
        continue
    sha, date = line.split()
    y, mo = int(date[:4]), int(date[5:7])
    ed = y + 1 if mo >= 8 else y
    text = subprocess.run(["git", "-C", repo, "show", f"{sha}:{path}"], capture_output=True, text=True).stdout
    rows = parse(text)
    for r in rows:
        first_seen.setdefault((ed, r["devroom"].lower()), date)
    if rows:
        editions[ed] = (sha, date, rows)

with open(os.path.join(out, "cfp_yaml.csv"), "w", newline="") as f:
    cw = csv.writer(f)
    cw.writerow(["edition", "day", "devroom", "announcement", "deadline", "first_listed", "last_commit"])
    for ed in sorted(editions):
        sha, date, rows = editions[ed]
        for r in rows:
            cw.writerow([ed, r["day"], r["devroom"], r["ann"], r["deadline"],
                         first_seen[(ed, r["devroom"].lower())], f"{date} {sha[:7]}"])
print({ed: len(v[2]) for ed, v in sorted(editions.items())})
