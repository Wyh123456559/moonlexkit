# Roadmap

## 0.3 — production lexical boundary

- [x] Configurable keyword classification.
- [x] Decimal, exponent, underscore, and hexadecimal integer literals.
- [x] Line and nested block comments.
- [x] Structured diagnostics for unknown characters, unterminated strings,
  delimiters, and retained unterminated block comments.
- [x] Recoverable `name = literal;` configuration-DSL parser.
- [x] Deterministic 10,000-line token-difference workload.

## Next steps

- [ ] Unicode identifier policy and explicit UTF-8 offset documentation.
- [ ] More literal classes, including binary and raw strings.
- [ ] Grammar-driven parser adapters for application-specific DSLs.
- [ ] Browser-facing Wasm visualizer built on the existing CLI JSON contract.
- [ ] 1k / 10k / 100k backend benchmark reports collected on one documented host.
