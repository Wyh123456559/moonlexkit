# Acceptance evidence

## Current verification commands

```bash
moon fmt --check
moon check --deny-warn --target all
moon info && git diff --exit-code -- '*.mbti'
moon test --deny-warn --target all
moon run cmd/main --target js
moon run bench/main --target js
```

MoonBit 0.10.4 no longer exposes `fmt/info --deny-warn`; CI detects those
legacy flags when available and otherwise uses the current non-mutating
equivalents.

## Functional scope

MoonLexKit scans configurable keywords, identifiers, decimal/hexadecimal
numbers, strings, line and nested block comments, whitespace, and symbols. It
maps offsets to line/columns, produces diagnostics, computes token diffs, and
parses recoverable `name = literal;` configuration statements. It is not a
complete parser generator or a replacement for the MoonBit language parser.

## Reproducible workload

`moon run bench/main --target js` scans two deterministic 10,000-line DSL
inputs (237,780 source units / 80,001 tokens) with a single edit. The expected
token diff contains one removed and one inserted token. This is a deterministic
regression workload, not a cross-machine latency claim.
