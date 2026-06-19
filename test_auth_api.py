# -*- coding: utf-8 -*-
import requests
import json
import time

BASE_URL = "https://remon132004-sayartii-api.hf.space/api/Account"
TIMEOUT = 120  # seconds - HF Spaces cold start can be slow

# ============================================================
# HELPER
# ============================================================
def print_result(title, response):
    print("\n" + "="*55)
    print(f"[TEST] {title}")
    print(f"Status Code : {response.status_code}")
    try:
        body = response.json()
        print(f"Response    :\n{json.dumps(body, indent=2, ensure_ascii=True)}")
    except Exception:
        print(f"Response    : {response.text}")
    print("="*55)

# ============================================================
# TEST 1 - Register a new user
# ============================================================
def test_register():
    print("\n--- TEST 1: Register new user ---")
    url = f"{BASE_URL}/register"
    payload = {
        "name": "Test User",
        "email": "testuser_api@sayartii.com",
        "password": "Test@1234"
    }
    print(f"[POST] {url}")
    response = requests.post(url, json=payload, timeout=TIMEOUT)
    print_result("REGISTER", response)
    return response

# ============================================================
# TEST 2 - Login with correct credentials
# ============================================================
def test_login(remember_me=False):
    print("\n--- TEST 2: Login (correct credentials) ---")
    url = f"{BASE_URL}/login"
    payload = {
        "email": "testuser_api@sayartii.com",
        "password": "Test@1234",
        "rememberMe": remember_me
    }
    print(f"[POST] {url}")
    response = requests.post(url, json=payload, timeout=TIMEOUT)
    print_result("LOGIN SUCCESS", response)
    return response

# ============================================================
# TEST 3 - Login with wrong password (expect 401)
# ============================================================
def test_login_wrong_password():
    print("\n--- TEST 3: Login (wrong password - expect 401) ---")
    url = f"{BASE_URL}/login"
    payload = {
        "email": "testuser_api@sayartii.com",
        "password": "WrongPassword!",
        "rememberMe": False
    }
    print(f"[POST] {url}")
    response = requests.post(url, json=payload, timeout=TIMEOUT)
    print_result("LOGIN WRONG PASSWORD", response)
    return response

# ============================================================
# TEST 4 - Register duplicate email (expect 400)
# ============================================================
def test_register_duplicate():
    print("\n--- TEST 4: Register duplicate email (expect 400) ---")
    url = f"{BASE_URL}/register"
    payload = {
        "name": "Duplicate User",
        "email": "testuser_api@sayartii.com",
        "password": "Test@1234"
    }
    print(f"[POST] {url}")
    response = requests.post(url, json=payload, timeout=TIMEOUT)
    print_result("REGISTER DUPLICATE", response)
    return response

# ============================================================
# RUN ALL TESTS
# ============================================================
if __name__ == "__main__":
    print("\n" + "*"*55)
    print("  Sayartii API - Auth Tests (Login & Register)")
    print(f"  Base URL: {BASE_URL}")
    print("*"*55)

    results = {}

    try:
        # Test 1: Register
        r = test_register()
        results["register"] = r.status_code

        time.sleep(1)

        # Test 2: Login (success)
        login_resp = test_login()
        results["login_ok"] = login_resp.status_code

        # Show JWT token
        if login_resp.status_code == 200:
            data = login_resp.json()
            token = data.get("token", "")
            exp   = data.get("expiration", "N/A")
            print(f"\n[OK] JWT Token (first 80 chars):\n{token[:80]}...")
            print(f"[OK] Expiration: {exp}")

        time.sleep(1)

        # Test 3: Login wrong password
        r3 = test_login_wrong_password()
        results["login_wrong"] = r3.status_code

        time.sleep(1)

        # Test 4: Duplicate register
        r4 = test_register_duplicate()
        results["register_dup"] = r4.status_code

    except requests.exceptions.ConnectionError as e:
        print(f"\n[ERR] Connection Error: {e}")
    except requests.exceptions.Timeout:
        print(f"\n[ERR] Timeout after {TIMEOUT}s - server may be sleeping. Try again.")
    except Exception as e:
        print(f"\n[ERR] Unexpected error: {e}")

    # Summary
    print("\n" + "*"*55)
    print("  SUMMARY")
    print("*"*55)
    checks = {
        "register"      : (200, 200),
        "login_ok"      : (200, 200),
        "login_wrong"   : (401, 401),
        "register_dup"  : (400, 400),
    }
    for key, (got_val) in results.items():
        expected = checks.get(key, (None, None))
        ok = "[PASS]" if got_val == expected[0] else "[FAIL]"
        print(f"  {ok}  {key:20s}  HTTP {got_val}  (expected {expected[0]})")
    print("*"*55 + "\n")
