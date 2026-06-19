import psycopg2, time

cfg = {
    'host': 'aws-1-eu-central-1.pooler.supabase.com',
    'port': 6543,
    'dbname': 'postgres',
    'user': 'postgres.iqmyxclsyulhegnrklvq',
    'password': 'remon25.jbu33775',
    'sslmode': 'require',
    'connect_timeout': 15,
    'keepalives': 1,
    'keepalives_idle': 15,
    'keepalives_interval': 5,
    'keepalives_count': 3,
}

host = cfg['host']
port = cfg['port']
print(f'Testing {host}:{port}...')
try:
    start = time.time()
    conn = psycopg2.connect(**cfg)
    elapsed = time.time() - start
    cur = conn.cursor()
    cur.execute('SELECT COUNT(*) FROM "AspNetUsers"')
    count = cur.fetchone()[0]
    print(f'  SUCCESS in {elapsed:.1f}s - Users in DB: {count}')
    
    # Now try INSERT to simulate what C# does
    print('  Testing INSERT...')
    import uuid
    test_id = str(uuid.uuid4())
    test_email = f'dbtest_{int(time.time())}@test.com'
    cur.execute(
        'INSERT INTO "AspNetUsers" ("Id","UserName","Email","Name","EmailConfirmed","PhoneNumberConfirmed","TwoFactorEnabled","LockoutEnabled","AccessFailedCount") VALUES (%s,%s,%s,%s,false,false,false,true,0)',
        (test_id, test_email, test_email, 'Test')
    )
    conn.commit()
    print(f'  INSERT SUCCESS!')
    # cleanup
    cur.execute('DELETE FROM "AspNetUsers" WHERE "Id"=%s', (test_id,))
    conn.commit()
    print(f'  CLEANUP SUCCESS! DB is fully writable.')
    conn.close()
except Exception as e:
    print(f'  FAILED: {type(e).__name__}: {e}')
