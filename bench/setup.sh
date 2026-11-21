#!/bin/sh
# Fetch jq's upstream test corpus and generate benchmark inputs into bench/data.
set -eu
cd "$(dirname "$0")"
mkdir -p data
for t in jq man onig optional base64 uri; do
    [ -s "data/$t.test" ] || curl -sSfL -m 30 "https://raw.githubusercontent.com/jqlang/jq/jq-1.8.1/tests/$t.test" -o "data/$t.test"
done
[ -s data/big.json ] || python3 - <<'EOF'
import json, random
random.seed(1)
words = ["alpha","beta","gamma","delta","\u00e9psilon","zeta","eta","theta","iota","kappa","lambda","mu"]
def rec(i):
    return {"id": i, "name": random.choice(words) + str(i), "score": random.random() * 1000,
            "active": random.random() < 0.5,
            "tags": [random.choice(words) for _ in range(random.randint(0, 5))],
            "nested": {"a": random.randint(0, 100), "b": [random.randint(0, 9) for _ in range(3)],
                       "c": None, "s": "x\"y\\z\n" * 2},
            "group": random.choice(words)}
data = [rec(i) for i in range(200000)]
json.dump(data, open("data/big.json", "w"))
with open("data/lines.ndjson", "w") as f:
    for r in data:
        f.write(json.dumps(r) + "\n")
json.dump(data[:20000], open("data/mid.json", "w"), indent=2)
json.dump(data[:2000], open("data/small.json", "w"))
EOF
echo "bench data ready in $(pwd)/data"
