#!/usr/bin/env python3
"""Benchmark jeqy against jq on representative workloads.

Usage: bench/bench.py [--bin ./jeqy] [--jq jq] [--runs 3] [--filter SUBSTR] [--timeout 60]

For each workload, runs both binaries (best of N wall-clock), verifies the
outputs are byte-identical, and prints the jeqy/jq time ratio. The summary
line reports the geometric mean ratio (lower is better; <= 1.0 means parity).
"""
import argparse, hashlib, math, os, subprocess, sys, time

HERE = os.path.dirname(os.path.abspath(__file__))
D = os.path.join(HERE, "data")

# (name, args, stdin-file or None)
WORKLOADS = [
    ("pretty_identity_mid", [".", f"{D}/mid.json"]),
    ("compact_identity_big", ["-c", ".", f"{D}/big.json"]),
    ("length_big", ["length", f"{D}/big.json"]),
    ("ndjson_field", [".name", f"{D}/lines.ndjson"]),
    ("ndjson_raw_field", ["-r", ".name", f"{D}/lines.ndjson"]),
    ("ndjson_select", ["-c", "select(.active and .score > 500) | {id, group}", f"{D}/lines.ndjson"]),
    ("map_add", ["map(.score) | add", f"{D}/big.json"]),
    ("select_count", ["[.[] | select(.active)] | length", f"{D}/big.json"]),
    ("group_by", ["-c", "group_by(.group) | map({k: .[0].group, n: length})", f"{D}/mid.json"]),
    ("sort_by", ["sort_by(.score) | .[0].id", f"{D}/mid.json"]),
    ("sort_numbers", ["[.[].score] | sort | .[10]", f"{D}/big.json"]),
    ("unique_by", ["-c", "unique_by(.group) | map(.id)", f"{D}/mid.json"]),
    ("join_tags", ["[.[] | .tags | join(\",\")] | length", f"{D}/big.json"]),
    ("tostring_all", ["map(tostring) | length", f"{D}/mid.json"]),
    ("tojson_fromjson", ["map(tojson | fromjson) | length", f"{D}/mid.json"]),
    ("reduce_range", ["-n", "reduce range(3000000) as $i (0; . + $i)"]),
    ("range_map_add", ["-n", "[range(1000000)] | map(. * 2) | add"]),
    ("to_entries", ["-c", "map(to_entries | from_entries) | length", f"{D}/mid.json"]),
    ("with_entries", ["-c", "map(with_entries(.value |= tostring)) | length", f"{D}/mid.json"]),
    ("update_assign", ["-c", "map(.nested.a |= . + 1) | map(.nested.a) | add", f"{D}/big.json"]),
    ("paths_count", ["[paths] | length", f"{D}/mid.json"]),
    ("regex_test", ["map(select(.name | test(\"^a.*[0-9]5$\"))) | length", f"{D}/mid.json"]),
    ("gsub", ["map(.name | gsub(\"a\"; \"A\")) | length", f"{D}/small.json"]),
    ("string_ops", ["map(.name | ascii_upcase | ltrimstr(\"A\") | split(\"\") | length) | add", f"{D}/mid.json"]),
    ("slurp_ndjson", ["-s", "length", f"{D}/lines.ndjson"]),
    ("object_construct", ["-c", "map({id, name, s: .nested.s, t: (.tags | length)}) | length", f"{D}/big.json"]),
    ("recurse_numbers", ["[.. | numbers] | add", f"{D}/mid.json"]),
    ("def_recursive", ["-n", "def f: if . < 25 then (. + 1 | f) + 1 else . end; [range(20000) | (0 | f)] | add"]),
    ("tostream", ["-c", "[tostream] | length", f"{D}/small.json"]),
    ("sort_keys", ["-S", "-c", ".", f"{D}/mid.json"]),
]


def run(cmd, timeout):
    t = time.perf_counter()
    try:
        p = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, timeout=timeout)
    except subprocess.TimeoutExpired:
        return None, None, None
    return time.perf_counter() - t, hashlib.sha256(p.stdout).hexdigest(), p.returncode


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--bin", default=os.path.join(HERE, "..", "jeqy"))
    ap.add_argument("--jq", default="jq")
    ap.add_argument("--runs", type=int, default=3)
    ap.add_argument("--timeout", type=float, default=60)
    ap.add_argument("--filter", default="")
    a = ap.parse_args()
    jeqy = os.path.abspath(a.bin)
    ratios = []
    mismatches = 0
    print(f"{'workload':24} {'jq s':>8} {'jeqy s':>8} {'ratio':>7}")
    for name, args in WORKLOADS:
        if a.filter and a.filter not in name:
            continue
        tj = tq = None
        hj = hq = None
        for _ in range(a.runs):
            t, h, rc = run([a.jq] + args, a.timeout)
            if t is not None and (tq is None or t < tq):
                tq, hq = t, h
            t, h, rc = run([jeqy] + args, a.timeout)
            if t is None:
                tj = None
                break
            if tj is None or t < tj:
                tj, hj = t, h
        if tj is None:
            print(f"{name:24} {tq:8.3f} {'TIMEOUT':>8}")
            ratios.append(a.timeout / tq)
            continue
        ratio = tj / tq
        ratios.append(ratio)
        flag = "" if hj == hq else "  OUTPUT MISMATCH"
        mismatches += hj != hq
        print(f"{name:24} {tq:8.3f} {tj:8.3f} {ratio:7.2f}{flag}", flush=True)
    if ratios:
        g = math.exp(sum(math.log(r) for r in ratios) / len(ratios))
        print(f"\ngeomean ratio (jeqy/jq): {g:.3f}   worst: {max(ratios):.2f}   mismatches: {mismatches}")


if __name__ == "__main__":
    main()
