# -*- coding: utf-8 -*-
import sys, io
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')

import requests, time, json

BACKEND_URL = "https://remon132004-sayartii-api.hf.space"
AI_URL      = "https://remon132004-sayartii-ai.hf.space"
TIMEOUT     = 45

results = []

def test(label, method, url, **kwargs):
    try:
        r = getattr(requests, method)(url, timeout=TIMEOUT, **kwargs)
        ok = "PASS" if r.status_code < 400 else "FAIL"
        snippet = r.text[:120].replace('\n','')
        results.append((ok, label, r.status_code, snippet))
        print(f"[{ok}] [{r.status_code}] {label}: {snippet}")
        return r
    except Exception as e:
        results.append(("ERR", label, "ERR", str(e)[:100]))
        print(f"[ERR] {label}: {e}")
        return None

print("=" * 60)
print("  SAYARTII FULL API AUDIT")
print("=" * 60)

# --- 1. Backend Health ---
print("\n[1/3] .NET BACKEND  ->", BACKEND_URL)
test("GET /", "get", f"{BACKEND_URL}/")
test("GET /swagger", "get", f"{BACKEND_URL}/swagger/index.html")

# Auth flow
ts = int(time.time())
email = f"audit_{ts}@sayartii.com"
test("POST /register", "post", f"{BACKEND_URL}/api/Account/register",
     json={"name":"AuditUser","email":email,"password":"Test1234"})

r_login = test("POST /login", "post", f"{BACKEND_URL}/api/Account/login",
               json={"email":email,"password":"Test1234","rememberMe":False})

token = None
if r_login and r_login.status_code == 200:
    token = r_login.json().get("token")
    print(f"   JWT acquired: {token[:40]}...")

test("POST /login (wrong pw)", "post", f"{BACKEND_URL}/api/Account/login",
     json={"email":email,"password":"WRONG","rememberMe":False})

test("POST /register (dup)", "post", f"{BACKEND_URL}/api/Account/register",
     json={"name":"Dup","email":email,"password":"Test1234"})

# Authenticated endpoint
if token:
    test("POST /api/Notifications", "post",
         f"{BACKEND_URL}/api/Notifications/Notifications",
         json={"notification":"Test audit notification"},
         headers={"Authorization": f"Bearer {token}"})

# --- 2. Flask / AI ---
print("\n[2/3] FLASK AI BACKEND  ->", AI_URL)
test("GET / (Flask)", "get", f"{AI_URL}/")

ai_data = {
    "engine_power":120.0,"engine_coolant_temp":95.0,
    "engine_load":40.0,"engine_rpm":1000.0,"air_intake_temp":30.0,
    "speed":50.0,"short_term_fuel_trim":0.0,
    "throttle_pos":20.0,"timing_advance":10.0
}
r_pred = test("POST /predict (normal)", "post", f"{AI_URL}/predict", json=ai_data)

# Predict a problem
ai_problem = dict(ai_data)
ai_problem["engine_coolant_temp"] = 105.0   # >90 triggers fallback "Problem Detected"
r_prob = test("POST /predict (problem)", "post", f"{AI_URL}/predict", json=ai_problem)

if r_prob and r_prob.status_code == 200:
    body = r_prob.json()
    pred   = body.get("prediction","?")
    code   = body.get("trouble_code","?")
    ai_rsp = body.get("openai_response",{})
    print(f"   prediction={pred}  trouble_code={code}")
    print(f"   openai_response type={type(ai_rsp).__name__}")

test("GET /dtc_code/P0101", "get", f"{AI_URL}/dtc_code/P0101")

# --- 3. Summary ---
print("\n" + "=" * 60)
print("  ENDPOINT SUMMARY")
print("=" * 60)
passed = sum(1 for r in results if r[0]=="PASS")
total  = len(results)
print(f"  PASSED: {passed}/{total}")
print()
for ok, label, code, _ in results:
    print(f"  {ok}  [{code}]  {label}")

print()
score = int(passed/total*100) if total else 0
print(f"  Backend Readiness: {score}%")
if score == 100:
    print("  ALL SYSTEMS GO! 🚀")
elif score >= 80:
    print("  MOSTLY READY — minor issues only")
else:
    print("  ⚠️  CRITICAL issues found — check output above")
