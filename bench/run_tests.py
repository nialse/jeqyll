#!/usr/bin/env python3
"""Run jq's upstream .test corpus against a jeqy binary.

Usage: bench/run_tests.py [--bin ./jeqy] [--baseline FILE] [--write-baseline FILE]

Prints pass/fail counts. With --baseline, exits non-zero if any case that
passed in the baseline file now fails (a regression).
"""
import argparse, concurrent.futures as cf, json, os, subprocess, sys

HERE = os.path.dirname(os.path.abspath(__file__))
DATA = os.path.join(HERE, "data")
SUITES = ["jq.test", "man.test", "onig.test", "optional.test", "base64.test", "uri.test"]


def parse(path):
    lines = open(path, encoding="utf-8", errors="surrogateescape").read().split("\n")
    cases, i, n = [], 0, len(lines)
    while i < n:
        line = lines[i]
        if not line.strip() or line.startswith("#"):
            i += 1
            continue
        fail = False
        start = i + 1
        if line.startswith("%%FAIL"):
            fail = True
            i += 1
            prog = lines[i] if i < n else ""
            i += 1
            expected = []
            while i < n and lines[i].strip():
                expected.append(lines[i]); i += 1
            cases.append({"id": f"{os.path.basename(path)}:{start}", "fail": True, "prog": prog,
                          "input": None, "expected": expected})
            continue
        prog = line
        i += 1
        inp = lines[i] if i < n else ""
        i += 1
        expected = []
        while i < n and lines[i].strip():
            expected.append(lines[i]); i += 1
        cases.append({"id": f"{os.path.basename(path)}:{start}", "fail": fail, "prog": prog,
                      "input": inp, "expected": expected})
    return cases


def norm(text):
    out = []
    for l in text:
        try:
            out.append(json.dumps(json.loads(l), sort_keys=False, separators=(",", ":")))
        except Exception:
            out.append(l.strip())
    return out


def run_case(binary, c):
    env = dict(os.environ, JQ_COLORS="", TZ="UTC", PAGER="cat")
    try:
        if c["fail"]:
            p = subprocess.run([binary, "-n", c["prog"]], capture_output=True, timeout=20, env=env, cwd=DATA)
            return c["id"], p.returncode != 0
        p = subprocess.run([binary, "-c", "-L", DATA, c["prog"]], input=(c["input"] + "\n").encode(),
                           capture_output=True, timeout=20, env=env, cwd=DATA)
        got = p.stdout.decode("utf-8", "surrogateescape").strip("\n")
        got_lines = [l for l in got.split("\n")] if got else []
        return c["id"], norm(got_lines) == norm(c["expected"])
    except subprocess.TimeoutExpired:
        return c["id"], False


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--bin", default=os.path.join(HERE, "..", "jeqy"))
    ap.add_argument("--baseline")
    ap.add_argument("--write-baseline")
    ap.add_argument("-v", action="store_true")
    a = ap.parse_args()
    binary = os.path.abspath(a.bin)
    cases = []
    for s in SUITES:
        p = os.path.join(DATA, s)
        if os.path.exists(p):
            cases += parse(p)
    with cf.ThreadPoolExecutor(os.cpu_count() or 4) as ex:
        results = dict(ex.map(lambda c: run_case(binary, c), cases))
    passed = sorted(k for k, v in results.items() if v)
    print(f"passed {len(passed)}/{len(results)}")
    if a.write_baseline:
        open(a.write_baseline, "w").write("\n".join(passed) + "\n")
    if a.baseline:
        base = set(l.strip() for l in open(a.baseline) if l.strip())
        regressions = sorted(base - set(passed))
        fixed = sorted(set(passed) - base)
        if fixed:
            print(f"newly passing: {len(fixed)}")
        if regressions:
            print(f"REGRESSIONS ({len(regressions)}):")
            byid = {c["id"]: c for c in cases}
            for r in regressions:
                print(f"  {r}: {byid[r]['prog']!r}  input={byid[r]['input']!r}")
            sys.exit(1)
        print("no regressions")


if __name__ == "__main__":
    main()
