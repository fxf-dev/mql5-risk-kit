# Symbol specification edge cases

MetaTrader 5 symbols can have different contract specifications depending on the broker, asset class, account type, and server configuration.

`RiskLotCalculator.mq5` uses the broker-provided symbol properties to estimate position size. Users should confirm these values before relying on the calculated lot size in live trading.

## Key symbol properties

The calculator depends mainly on the following MT5 symbol properties:

```text
SYMBOL_TRADE_TICK_SIZE
SYMBOL_TRADE_TICK_VALUE
SYMBOL_VOLUME_MIN
SYMBOL_VOLUME_MAX
SYMBOL_VOLUME_STEP
SYMBOL_DIGITS
```

## Why tick value matters

The core formula is:

```text
loss_per_1_lot =
    (abs(entry_price - stop_loss_price) / tick_size) * tick_value
```

If `SYMBOL_TRADE_TICK_VALUE` differs from what the user expects, the calculated lot size can also differ.

This is especially important for:

- metals
- indices
- crypto CFDs
- synthetic symbols
- broker-specific CFD symbols
- symbols with non-standard contract sizes

## FX pairs

For major FX pairs, tick size and tick value are often relatively stable, but users should still confirm:

- account currency
- quote currency
- contract size
- tick value
- volume step

Even for FX, tick value may vary when the account currency differs from the quote currency.

## Metals

Gold and silver symbols can vary significantly between brokers.

Examples of broker-specific differences:

- `XAUUSD` contract size
- `XAGUSD` contract size
- minimum volume
- volume step
- tick value
- tick size

Users should not assume that one broker's metal specification matches another broker's specification.

## Indices and CFDs

Index CFDs often use broker-specific contract specifications.

Users should confirm:

- whether one lot represents one index unit or a larger contract
- tick size
- tick value
- minimum lot
- volume step
- margin requirements

## Crypto CFDs

Crypto CFDs can also vary by broker.

Users should confirm:

- contract size
- tick value
- tick size
- trading hours
- minimum and maximum volume
- volume step

## Recommended verification workflow

Before using the calculated volume in live trading:

1. Run `RiskLotCalculator.mq5` with `InpPrintSymbolSpec = true`.
2. Check the printed symbol specification.
3. Compare tick size and tick value with the broker's contract specification page.
4. Test the calculated volume on a demo account.
5. Confirm estimated loss using the broker's order window or position preview if available.

## Known limitation

`RiskLotCalculator.mq5` estimates risk using the current broker-provided tick size and tick value. It does not guarantee that every broker, symbol, or asset class will behave identically.

Users are responsible for confirming broker-specific specifications before live use.
