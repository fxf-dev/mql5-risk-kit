# Position-size examples

These examples illustrate the formula. Real broker specifications may differ.

## Example 1: FX

```text
entry = 1.10000
stop_loss = 1.09500
risk_money = 100
tick_size = 0.00001
tick_value = 1.00
```

```text
price_distance = 0.00500
loss_per_1_lot = (0.00500 / 0.00001) * 1.00 = 500
raw_lots = 100 / 500 = 0.20
```

## Example 2: Gold / CFD

For XAUUSD and CFDs, always confirm the broker's `SYMBOL_TRADE_TICK_SIZE` and `SYMBOL_TRADE_TICK_VALUE`.

The same price-distance formula is used, but the symbol contract specification determines the actual risk per lot.
