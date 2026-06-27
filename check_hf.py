import requests

token = "YOUR_HF_TOKEN"
url = "https://huggingface.co/api/spaces/remon132004/sayartii-api"
headers = {"Authorization": f"Bearer {token}"}

response = requests.get(url, headers=headers)
if response.status_code == 200:
    data = response.json()
    print("Runtime Env Vars:", data.get("runtime", {}).get("env", []))
    print("Variables:", data.get("variables", {}))
    # Note: secrets won't show values, but sometimes show keys if we query the spaces/{space}/secrets endpoint
else:
    print("Failed", response.status_code, response.text)
