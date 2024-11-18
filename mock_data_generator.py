import snowflake.connector
import random
from datetime import datetime, timedelta
import time

# Snowflake connection parameters
user = 'admin'
password = 'admin'
account = 'guxyhix-bq1234'
warehouse = 'COMPUTE_WH'
database = 'PAT'
schema = 'PUBLIC'

# Establish a connection to Snowflake
conn = snowflake.connector.connect(
    user=user,
    password=password,
    account=account,
    warehouse=warehouse,
    database=database,
    schema=schema
)

# Create a cursor object
cur = conn.cursor()

# Function to generate mock CDC events for bronze_trades
def generate_mock_data(trade_id=None):
    if trade_id is None:
        trade_id = f'TRADE{random.randint(1, 100)}'  # Use fewer random trade_ids
    trader_id = f'TRADER{random.randint(1, 50)}'
    instrument_type = random.choice(['ZQ', 'SR1', 'SR3', 'EOFR'])
    trade_type = random.choice(['BUY', 'SELL'])
    execution_time = datetime.now() - timedelta(minutes=random.randint(0, 1440))  # Random within the last day
    trade_price = round(random.uniform(50.0, 1000.0), 2)  # Random price between 50 and 1000
    trade_volume = random.randint(1, 1000)
    profit_loss = round(random.uniform(-1000.0, 1000.0), 2)  # Random profit/loss
    open_interest = random.randint(100, 10000)
    strategy_id = f'STRATEGY{random.randint(1, 10)}'
    
    return (trade_id, trader_id, instrument_type, trade_type, execution_time, trade_price, trade_volume, profit_loss, open_interest, strategy_id)

# Function to insert data into Snowflake
def insert_data_to_snowflake(data):
    cur.execute(
        """
        INSERT INTO bronze_trades (trade_id, trader_id, instrument_type, trade_type, execution_time, trade_price, trade_volume, profit_loss, open_interest, strategy_id) 
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        """,
        data
    )
    conn.commit()
    print(f"Inserted: {data}")

# Function to update data in Snowflake
def update_data_in_snowflake(trade_id):
    new_trade_price = round(random.uniform(50.0, 1000.0), 2)
    new_trade_volume = random.randint(1, 1000)
    new_profit_loss = round(random.uniform(-1000.0, 1000.0), 2)
    
    cur.execute(
        """
        UPDATE bronze_trades 
        SET trade_price = %s, trade_volume = %s, profit_loss = %s 
        WHERE trade_id = %s
        """,
        (new_trade_price, new_trade_volume, new_profit_loss, trade_id)
    )
    conn.commit()
    print(f"Updated trade_id: {trade_id}")

# Function to delete data from Snowflake
def delete_data_from_snowflake(trade_id):
    cur.execute(
        """
        DELETE FROM bronze_trades 
        WHERE trade_id = %s
        """,
        (trade_id,)
    )
    conn.commit()
    print(f"Deleted trade_id: {trade_id}")

# Function to continuously insert data
def continuous_insert():
    try:
        while True:
            data = generate_mock_data()
            print(data)
            insert_data_to_snowflake(data)
            time.sleep(5)  # Wait for 5 seconds before the next insert
    except KeyboardInterrupt:
        print("Stopping data generation...")
    finally:
        cur.close()
        conn.close()

# Start continuous insert
if __name__ == "__main__":
    continuous_insert()

# Example usage of update and delete functions
# You can call these functions as needed for ad-hoc updates and deletes (CDC operations)
# update_data_in_snowflake('TRADE1')
# delete_data_from_snowflake('TRADE3')
