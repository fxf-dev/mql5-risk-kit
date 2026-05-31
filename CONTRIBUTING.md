# Contributing

Contributions are welcome.

Useful contributions include:

- bug reports for symbol-specific edge cases
- examples from different brokers
- documentation improvements
- formula validation
- MQL5 code improvements

## Development rules

1. Keep tools strategy-neutral.
2. Do not add proprietary trading signals or entry logic.
3. Prefer transparent formulas over hidden behavior.
4. Round volume down when the goal is risk control.
5. Document broker-specific assumptions.

## Pull request checklist

- [ ] The change is explained clearly.
- [ ] The formula impact is documented.
- [ ] The tool still does not place orders unless explicitly documented.
- [ ] New examples are anonymized and do not expose private account data.
