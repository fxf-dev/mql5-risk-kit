//+------------------------------------------------------------------+
//| RiskLotCalculator.mq5                                            |
//| Open-source position-size calculator for MetaTrader 5 / MQL5.     |
//|                                                                  |
//| This script does not place orders. It only prints calculated risk |
//| and volume information for the selected symbol.                   |
//+------------------------------------------------------------------+
#property strict
#property script_show_inputs
#property version   "0.1.0"
#property description "Calculate MT5 lot size from entry, stop loss, and risk amount."

input string InpSymbol = "";                 // Symbol. Empty = current chart symbol.
input double InpEntryPrice = 0.0;             // Entry price. 0 = current mid price.
input double InpStopLossPrice = 0.0;          // Stop-loss price.
input double InpRiskMoney = 100.0;            // Risk amount in account currency.
input bool   InpPrintSymbolSpec = true;       // Print tick/volume specification.

//+------------------------------------------------------------------+
bool ReadSymbolDouble(const string symbol,
                      const ENUM_SYMBOL_INFO_DOUBLE property,
                      double &value)
{
   ResetLastError();
   if(!SymbolInfoDouble(symbol, property, value))
   {
      PrintFormat("SymbolInfoDouble failed. symbol=%s property=%d error=%d",
                  symbol, (int)property, GetLastError());
      return false;
   }
   return true;
}

//+------------------------------------------------------------------+
int DigitsFromStep(double step)
{
   int digits = 0;
   while(digits < 8 && MathAbs(step - MathRound(step)) > 1e-10)
   {
      step *= 10.0;
      digits++;
   }
   return digits;
}

//+------------------------------------------------------------------+
double RoundVolumeDown(const string symbol, const double raw_volume)
{
   double min_volume = 0.0;
   double max_volume = 0.0;
   double step       = 0.0;

   if(!ReadSymbolDouble(symbol, SYMBOL_VOLUME_MIN,  min_volume)) return 0.0;
   if(!ReadSymbolDouble(symbol, SYMBOL_VOLUME_MAX,  max_volume)) return 0.0;
   if(!ReadSymbolDouble(symbol, SYMBOL_VOLUME_STEP, step))       return 0.0;

   if(raw_volume <= 0.0 || step <= 0.0)
      return 0.0;

   double rounded = MathFloor((raw_volume + 1e-12) / step) * step;

   if(rounded < min_volume)
      return 0.0;

   if(rounded > max_volume)
      rounded = max_volume;

   return NormalizeDouble(rounded, DigitsFromStep(step));
}

//+------------------------------------------------------------------+
bool GetCurrentMidPrice(const string symbol, double &mid_price)
{
   double bid = 0.0;
   double ask = 0.0;

   if(!ReadSymbolDouble(symbol, SYMBOL_BID, bid)) return false;
   if(!ReadSymbolDouble(symbol, SYMBOL_ASK, ask)) return false;

   if(bid <= 0.0 || ask <= 0.0)
   {
      PrintFormat("Invalid bid/ask. symbol=%s bid=%f ask=%f", symbol, bid, ask);
      return false;
   }

   mid_price = (bid + ask) / 2.0;
   return true;
}

//+------------------------------------------------------------------+
void PrintSymbolSpec(const string symbol)
{
   double tick_size   = 0.0;
   double tick_value  = 0.0;
   double min_volume  = 0.0;
   double max_volume  = 0.0;
   double step        = 0.0;

   if(!ReadSymbolDouble(symbol, SYMBOL_TRADE_TICK_SIZE, tick_size))  return;
   if(!ReadSymbolDouble(symbol, SYMBOL_TRADE_TICK_VALUE, tick_value)) return;
   if(!ReadSymbolDouble(symbol, SYMBOL_VOLUME_MIN, min_volume))       return;
   if(!ReadSymbolDouble(symbol, SYMBOL_VOLUME_MAX, max_volume))       return;
   if(!ReadSymbolDouble(symbol, SYMBOL_VOLUME_STEP, step))            return;

   PrintFormat("Symbol spec: %s", symbol);
   PrintFormat("  tick_size=%.*f", 10, tick_size);
   PrintFormat("  tick_value=%.*f", 10, tick_value);
   PrintFormat("  volume_min=%.*f", 8, min_volume);
   PrintFormat("  volume_max=%.*f", 8, max_volume);
   PrintFormat("  volume_step=%.*f", 8, step);
}

//+------------------------------------------------------------------+
void OnStart()
{
   const string symbol = (InpSymbol == "" ? _Symbol : InpSymbol);

   if(!SymbolSelect(symbol, true))
   {
      PrintFormat("SymbolSelect failed: %s", symbol);
      return;
   }

   if(InpRiskMoney <= 0.0)
   {
      Print("InpRiskMoney must be greater than 0.");
      return;
   }

   double entry = InpEntryPrice;
   if(entry <= 0.0)
   {
      if(!GetCurrentMidPrice(symbol, entry))
         return;
   }

   const double stop_loss = InpStopLossPrice;
   if(stop_loss <= 0.0)
   {
      Print("InpStopLossPrice must be greater than 0.");
      return;
   }

   const double price_distance = MathAbs(entry - stop_loss);
   if(price_distance <= 0.0)
   {
      Print("Entry price and stop-loss price must be different.");
      return;
   }

   double tick_size  = 0.0;
   double tick_value = 0.0;

   if(!ReadSymbolDouble(symbol, SYMBOL_TRADE_TICK_SIZE, tick_size))  return;
   if(!ReadSymbolDouble(symbol, SYMBOL_TRADE_TICK_VALUE, tick_value)) return;

   if(tick_size <= 0.0 || tick_value <= 0.0)
   {
      PrintFormat("Invalid tick specification. tick_size=%f tick_value=%f",
                  tick_size, tick_value);
      return;
   }

   const double loss_per_1_lot = (price_distance / tick_size) * tick_value;
   if(loss_per_1_lot <= 0.0)
   {
      Print("Calculated loss_per_1_lot is invalid.");
      return;
   }

   const double raw_lots      = InpRiskMoney / loss_per_1_lot;
   const double rounded_lots  = RoundVolumeDown(symbol, raw_lots);
   const double rounded_risk  = rounded_lots * loss_per_1_lot;

   Print("------------------------------------------------------------");
   Print("RiskLotCalculator");
   PrintFormat("symbol=%s", symbol);
   PrintFormat("entry=%.*f stop_loss=%.*f", _Digits, entry, _Digits, stop_loss);
   PrintFormat("risk_money=%.2f", InpRiskMoney);
   PrintFormat("price_distance=%.*f", _Digits, price_distance);
   PrintFormat("loss_per_1_lot=%.2f", loss_per_1_lot);
   PrintFormat("raw_lots=%.8f", raw_lots);
   PrintFormat("rounded_lots=%.8f", rounded_lots);
   PrintFormat("estimated_risk_after_rounding=%.2f", rounded_risk);

   if(rounded_lots <= 0.0)
      Print("Warning: calculated volume is below the symbol's minimum volume.");

   if(InpPrintSymbolSpec)
      PrintSymbolSpec(symbol);

   Print("------------------------------------------------------------");
}
//+------------------------------------------------------------------+
