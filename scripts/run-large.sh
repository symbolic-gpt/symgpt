#!/usr/bin/env bash
set -euo pipefail

OUT_DIR="local/large"
mkdir -p "$OUT_DIR"

for sol_file in benchmark/large/*.sol; do
	[ -e "$sol_file" ] || continue
	./x audit "$sol_file" --out-dir "$OUT_DIR"
done