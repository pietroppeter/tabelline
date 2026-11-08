"""Flatten the fosdem@lists.fosdem.org archive (mbox export, 2006-) into a staging CSV.

Usage: python3 -I extract_lists.py <fosdem.mbox> <stage dir>
Keeps sender *names* only (no e-mail addresses) and no message bodies, apart from
a few fields read from them: the FOSDEM year they mention and the first pretalx /
CfP link. Cleaning and classification happen in nanuq (process.nim).
"""
import csv, email.header, email.utils, mailbox, os, re, sys

src, out = sys.argv[1], sys.argv[2]

def dec(v):
    if v is None:
        return ""
    try:
        parts = email.header.decode_header(str(v))
        s = "".join(p.decode(c or "utf-8", "replace") if isinstance(p, bytes) else p for p, c in parts)
    except Exception:
        s = str(v)
    return re.sub(r"\s+", " ", s).strip()

def body(m):
    for part in (m.walk() if m.is_multipart() else [m]):
        if part.get_content_type() == "text/plain":
            try:
                return part.get_payload(decode=True).decode(part.get_content_charset() or "utf-8", "replace")
            except Exception:
                return ""
    return ""

rows = []
for m in mailbox.mbox(src):
    try:
        d = email.utils.parsedate_to_datetime(m["date"])
    except Exception:
        d = None
    name, addr = email.utils.parseaddr(dec(m["from"]))
    name = name.strip().strip('"').strip("'")
    if not name or "@" in name:
        name = addr.split("@")[0] if addr else ""
        name = re.sub(r"\s+at\s+.*", "", name)
    subj = dec(m["subject"])
    b = body(m)
    years = re.findall(r"FOSDEM\s*'?(20\d\d|\d\d)\b", subj + " " + b[:3000], re.I)
    years = sorted({int(y) if len(y) == 4 else 2000 + int(y) for y in years})
    link = re.search(r"https?://(?:pretalx\.fosdem\.org|penta\.fosdem\.org)[^\s>)\]]*", b)
    rows.append([
        d.date().isoformat() if d else "", d.year if d else "", name, subj,
        1 if re.match(r"\s*(re|aw|sv)\s*:", re.sub(r"^\[FOSDEM\]\s*", "", subj, flags=re.I), re.I) else 0,
        " ".join(map(str, years)), link.group(0) if link else "",
        len(b),
    ])
rows.sort(key=lambda r: r[0])
with open(os.path.join(out, "list_messages.csv"), "w", newline="") as f:
    cw = csv.writer(f)
    cw.writerow(["date", "year", "sender", "subject", "is_reply", "years_mentioned", "pretalx_link", "body_chars"])
    cw.writerows(rows)
print(len(rows), "messages")
