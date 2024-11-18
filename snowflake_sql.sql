CREATE DATABASE PAT;

USE PAT;

--bronze table
CREATE OR REPLACE TABLE bronze_trades (
    trade_id STRING PRIMARY KEY,
    trader_id STRING,
    instrument_type STRING,
    trade_type STRING,
    execution_time TIMESTAMP,
    trade_price FLOAT,
    trade_volume INT,
    profit_loss FLOAT,
    open_interest INT,
    strategy_id STRING
);

-- silver table
CREATE OR REPLACE DYNAMIC TABLE silver_trades 
WAREHOUSE = 'COMPUTE_WH'
TARGET_LAG = DOWNSTREAM
AS
SELECT
    trade_id,
    trader_id,
    instrument_type,
    trade_type,
    execution_time,
    trade_price,
    trade_volume,
    profit_loss,
    open_interest,
    strategy_id,
    -- Derived columns
    SUM(profit_loss) OVER (PARTITION BY trader_id ORDER BY execution_time) AS cumulative_pnl,
    CASE
        WHEN profit_loss > 0 THEN 'Profitable'
        ELSE 'Loss-Making'
    END AS trade_outcome,
    AVG(trade_price) OVER (PARTITION BY instrument_type, CAST(execution_time AS DATE)) AS avg_trade_price,
    MAX(trade_volume) OVER (PARTITION BY trader_id, CAST(execution_time AS DATE)) AS max_daily_volume
FROM bronze_trades;


-- 1) Gold Table for Overall Trader Performance

CREATE OR REPLACE DYNAMIC TABLE gold_trader_performance
WAREHOUSE = 'COMPUTE_WH'
TARGET_LAG = DOWNSTREAM
AS
SELECT
    trader_id,
    COUNT(trade_id) AS total_trades,
    SUM(profit_loss) AS total_profit_loss,
    AVG(trade_volume) AS avg_trade_volume,
    (COUNT(CASE WHEN profit_loss > 0 THEN 1 END) * 100.0) / COUNT(trade_id) AS win_rate,
    MAX(cumulative_pnl) AS peak_cumulative_pnl,
    MIN(cumulative_pnl) AS lowest_cumulative_pnl
FROM silver_trades
GROUP BY trader_id;


-- 2) Gold Table for Instrument Analysis

CREATE OR REPLACE DYNAMIC TABLE gold_instrument_performance
WAREHOUSE = 'COMPUTE_WH'
TARGET_LAG = DOWNSTREAM
AS
SELECT
    instrument_type,
    COUNT(trade_id) AS total_trades,
    SUM(profit_loss) AS total_profit_loss,
    AVG(trade_price) AS avg_trade_price,
    STDDEV(trade_price) AS price_volatility,
    SUM(trade_volume) AS total_volume_traded,
    AVG(profit_loss) AS avg_profit_per_trade
FROM silver_trades
GROUP BY instrument_type;

-- 3) Gold Table for Strategy Effectiveness

CREATE OR REPLACE DYNAMIC TABLE gold_strategy_performance
WAREHOUSE = 'COMPUTE_WH'
TARGET_LAG = DOWNSTREAM
AS
SELECT
    strategy_id,
    COUNT(trade_id) AS total_trades,
    SUM(profit_loss) AS total_profit_loss,
    (COUNT(CASE WHEN profit_loss > 0 THEN 1 END) * 100.0) / COUNT(trade_id) AS strategy_win_rate,
    AVG(profit_loss) AS avg_profit_per_strategy,
    SUM(trade_volume) AS total_volume_traded
FROM silver_trades
GROUP BY strategy_id;

-- 4) Gold Table for Time-Based Trading Performance

CREATE OR REPLACE DYNAMIC TABLE gold_time_based_performance
WAREHOUSE = 'COMPUTE_WH'
TARGET_LAG = DOWNSTREAM
AS
SELECT
    CAST(execution_time AS DATE) AS trade_date,
    EXTRACT(HOUR FROM execution_time) AS trade_hour,
    trader_id,
    COUNT(trade_id) AS trades_per_hour,
    SUM(profit_loss) AS hourly_profit_loss,
    AVG(trade_volume) AS avg_hourly_volume,
    MAX(cumulative_pnl) AS peak_hourly_cumulative_pnl
FROM silver_trades
GROUP BY CAST(execution_time AS DATE), EXTRACT(HOUR FROM execution_time), trader_id;

--5) Gold Table for Trader Peer Comparison

CREATE OR REPLACE DYNAMIC TABLE gold_trader_comparison
WAREHOUSE = 'COMPUTE_WH'
TARGET_LAG = DOWNSTREAM
AS
SELECT
    trader_id,
    COUNT(trade_id) AS total_trades,
    SUM(profit_loss) AS total_profit_loss,
    AVG(profit_loss) AS avg_profit_per_trade,
    AVG(trade_volume) AS avg_trade_volume,
    RANK() OVER (ORDER BY SUM(profit_loss) DESC) AS profit_rank,
    PERCENT_RANK() OVER (ORDER BY SUM(profit_loss)) AS percentile_rank
FROM silver_trades
GROUP BY trader_id;


CREATE OR REPLACE TASK gold_trader_performance_refresh
WAREHOUSE='COMPUTE_WH'
SCHEDULE='2 MINUTE'
AS
ALTER DYNAMIC TABLE gold_trader_performance REFRESH;

CREATE OR REPLACE TASK refresh_gold_instrument_performance
WAREHOUSE = 'COMPUTE_WH'
SCHEDULE = '10 MINUTE'
AS
ALTER DYNAMIC TABLE gold_instrument_performance REFRESH;

CREATE OR REPLACE TASK refresh_gold_strategy_performance
WAREHOUSE = 'COMPUTE_WH'
SCHEDULE = '10 MINUTE'
AS
ALTER DYNAMIC TABLE gold_strategy_performance REFRESH;

CREATE OR REPLACE TASK refresh_gold_time_based_performance
WAREHOUSE = 'COMPUTE_WH'
SCHEDULE = '10 MINUTE'
AS
ALTER DYNAMIC TABLE gold_time_based_performance REFRESH;

CREATE OR REPLACE TASK refresh_gold_trader_comparison
WAREHOUSE = 'COMPUTE_WH'
SCHEDULE = '10 MINUTE'
AS
ALTER DYNAMIC TABLE gold_trader_comparison REFRESH;
