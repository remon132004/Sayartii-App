import os

base_path = r"d:\flutter\Sayartii-Server"

# Create README.md for flask_backend
flask_readme_path = os.path.join(base_path, "flask_backend", "README.md")
flask_readme_content = """---
title: Sayartii AI
emoji: 🚗
colorFrom: blue
colorTo: indigo
sdk: docker
pinned: false
---

# Sayartii AI Model Backend
"""
with open(flask_readme_path, "w", encoding="utf-8") as f:
    f.write(flask_readme_content)
print("Created flask_backend/README.md")

# Create README.md for backend
backend_readme_path = os.path.join(base_path, "backend", "README.md")
backend_readme_content = """---
title: Sayartii API
emoji: ⚡
colorFrom: green
colorTo: purple
sdk: docker
pinned: false
---

# Sayartii .NET API
"""
with open(backend_readme_path, "w", encoding="utf-8") as f:
    f.write(backend_readme_content)
print("Created backend/README.md")
