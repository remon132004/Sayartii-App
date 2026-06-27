import os

file_path = r"d:\flutter\Sayartii-Server\backend\appsettings.json"

with open(file_path, "r", encoding="utf-8") as f:
    content = f.read()

# Make sure we replace it cleanly
if "Port=5432" in content:
    content = content.replace("Port=5432", "Port=6543")

# Ensure Pooling=false is added if not exists
if "Pooling=false" not in content:
    content = content.replace("Trust Server Certificate=true", "Trust Server Certificate=true;Pooling=false")

with open(file_path, "w", encoding="utf-8") as f:
    f.write(content)

print("Updated config for robust transaction pooler.")
