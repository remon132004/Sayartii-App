import os

file_path = r"d:\flutter\Sayartii-Server\backend\appsettings.json"

with open(file_path, "r", encoding="utf-8") as f:
    content = f.read()

# Replace Port=6543 with Port=5432
content = content.replace("Port=6543", "Port=5432")
# Append Pooling=true just in case (npgsql defaults to true but session pooling handles it)

with open(file_path, "w", encoding="utf-8") as f:
    f.write(content)

print("Port updated mapped to 5432 for Session Pooling.")
