import requests, time, json

BASE = 'https://remon132004-sayartii-api.hf.space/api/Account'
ts = int(time.time())
email = f'newtest_{ts}@sayartii.com'

print(f'Email: {email}')
r = requests.post(f'{BASE}/register',
    json={'name': 'Fresh User', 'email': email, 'password': 'Hello@123'},
    timeout=90)
print(f'Status: {r.status_code}')
try:
    body = r.json()
    print(json.dumps(body, indent=2))
except:
    print(r.text[:2000])
