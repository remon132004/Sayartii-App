import requests

url = "https://remon132004-sayartii-ai.hf.space/predict"
data = {
    "engine_power": 120.0,
    "engine_coolant_temp": 95.0,
    "engine_load": 40.0,
    "engine_rpm": 1000.0,
    "air_intake_temp": 30.0,
    "speed": 50.0,
    "short_term_fuel_trim": 0.0,
    "throttle_pos": 20.0,
    "timing_advance": 10.0
}

try:
    response = requests.post(url, json=data, timeout=30)
    print("Status Code:", response.status_code)
    print("Response Text:", response.text)
except Exception as e:
    print("Error:", e)
