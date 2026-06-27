import os

file_path = r"d:\flutter\Sayartii-Server\backend\appsettings.json"

with open(file_path, "r", encoding="utf-8") as f:
    content = f.read()

content = content.replace("YOUR_ACTUAL_PASSWORD", "remon25.jbu33775")

with open(file_path, "w", encoding="utf-8") as f:
    f.write(content)

print("Password updated successfully.")
