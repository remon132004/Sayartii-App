import requests, time

BASE = 'https://remon132004-sayartii-api.hf.space/api/Account'
ts = int(time.time())
email = f'newtest_{ts}@sayartii.com'

print(f'Testing with fresh email: {email}')

r = requests.post(f'{BASE}/register', json={'name':'Fresh User','email':email,'password':'Hello@123'}, timeout=60)
print(f'Register  -> {r.status_code}  {r.text[:80]}')

r2 = requests.post(f'{BASE}/login', json={'email':email,'password':'Hello@123','rememberMe':False}, timeout=60)
token_preview = r2.json().get('token','')[:60] + '...' if r2.status_code == 200 else r2.text[:80]
print(f'Login OK  -> {r2.status_code}  {token_preview}')

r3 = requests.post(f'{BASE}/login', json={'email':email,'password':'WRONG','rememberMe':False}, timeout=60)
print(f'Login Bad -> {r3.status_code}')

r4 = requests.post(f'{BASE}/register', json={'name':'Dup','email':email,'password':'Hello@123'}, timeout=60)
print(f'Dup Reg   -> {r4.status_code}  {r4.text[:80]}')

all_ok = r.status_code==200 and r2.status_code==200 and r3.status_code==401 and r4.status_code==400
print()
print('ALL PASS!' if all_ok else 'Some tests failed')
