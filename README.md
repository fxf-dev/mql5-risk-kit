# mql5-risk-kit

Open-source risk-management utilities for MetaTrader 5 / MQL5.

The first tool is a transparent position-size calculator that converts:

- entry price
- stop-loss price
- fixed risk amount, balance-percent risk, or equity-percent risk
- broker symbol properties

into a volume/lot size that is rounded down to the symbol's allowed volume step.

This project intentionally focuses on **risk tooling**, not proprietary entry logic.

## Why this exists

Manual lot calculation is error-prone, especially when trading different symbols, CFDs, metals, indices, or prop-firm accounts. This repository keeps the formula and implementation public so that traders can audit, improve, and adapt the tool.

## Current tool

### `src/RiskLotCalculator.mq5`

A MetaTrader 5 script. Attach it to a chart, enter the entry price, stop-loss price, and risk settings, and it prints:

- selected risk mode
- calculated risk amount
- raw lot size
- rounded lot size
- estimated risk after rounding
- symbol tick size / tick value / volume limits

## Risk modes

`RiskLotCalculator.mq5` supports three risk calculation modes:

```text
RISK_FIXED_MONEY
RISK_BALANCE_PERCENT
RISK_EQUITY_PERCENT
```

### Fixed money mode

Use `InpRiskMoney` directly as the risk amount in account currency.

Example:

```text
InpRiskMode  = RISK_FIXED_MONEY
InpRiskMoney = 100.0
```

### Balance-percent mode

Calculate the risk amount from account balance and `InpRiskPercent`.

Example:

```text
InpRiskMode    = RISK_BALANCE_PERCENT
InpRiskPercent = 1.0
```

### Equity-percent mode

Calculate the risk amount from account equity and `InpRiskPercent`.

Example:

```text
InpRiskMode    = RISK_EQUITY_PERCENT
InpRiskPercent = 1.0
```

## Formula

```text
price_distance = abs(entry_price - stop_loss_price)

loss_per_1_lot =
    (price_distance / tick_size) * tick_value

raw_lots =
    risk_money / loss_per_1_lot
```

The result is rounded **down** to the broker's `SYMBOL_VOLUME_STEP` so that the final risk does not exceed the intended risk.

## Installation

1. Download `src/RiskLotCalculator.mq5`.
2. Copy it to your MT5 data folder:

```text
MQL5/Scripts/RiskLotCalculator.mq5
```

3. Restart MT5 or refresh the Navigator.
4. Run the script from `Scripts`.
5. Enter:
   - `InpEntryPrice`
   - `InpStopLossPrice`
   - `InpRiskMode`
   - `InpRiskMoney` for fixed-money mode, or `InpRiskPercent` for percent-risk modes
## Documentation

- [Symbol specification edge cases](docs/symbol-spec-edge-cases.md)
  
## Safety notes

This script does not place orders. It only calculates volume.

Always confirm the result against your broker's contract specification before live use. Tick value behavior can differ across symbols and brokers.

## Roadmap

- [ ] Add optional chart object reading for entry/SL lines.
- [x] Add account-balance percentage risk mode.
- [ ] Add multi-symbol examples.
- [ ] Add CSV export for calculated scenarios.
- [ ] Add unit-testable formula mirror in Python for validation.
- [x] Add documentation for metals, indices, FX, and crypto CFDs.

## Contributing

Bug reports, symbol-specific examples, broker-specific edge cases, and documentation improvements are welcome.

See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

MIT. See [LICENSE](LICENSE).
