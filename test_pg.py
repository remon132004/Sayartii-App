import psycopg2

try:
    conn = psycopg2.connect(
        host="aws-1-eu-central-1.pooler.supabase.com",
        port=6543,
        database="postgres",
        user="postgres.iqmyxclsyulhegnrklvq",
        password="remon25.jbu33775",
        connect_timeout=10
    )
    print("Direct connection to Supabase successful!")
    conn.close()
except Exception as e:
    print("Connection failed:", e)
