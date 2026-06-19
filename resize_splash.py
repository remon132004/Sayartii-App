from PIL import Image
import os
import shutil

img_path = r'd:\flutter\sayartii\assets\images\perfect_splash_icon_hq.png'
backup_path = r'd:\flutter\sayartii\assets\images\perfect_splash_icon_hq_backup.png'

# Create a backup
if not os.path.exists(backup_path):
    shutil.copy2(img_path, backup_path)
else:
    # If backup exists, we probably want to scale from the original backup to prevent double-scaling
    shutil.copy2(backup_path, img_path)

img = Image.open(img_path)
img = img.convert("RGBA")

width, height = img.size

# To make the logo smaller, we enlarge the transparent canvas.
# A 1.5 multiplier makes the logo appear ~33% smaller on screen.
multiplier = 1.5
new_width = int(width * multiplier)
new_height = int(height * multiplier)

new_img = Image.new('RGBA', (new_width, new_height), (0, 0, 0, 0))

x = (new_width - width) // 2
y = (new_height - height) // 2

new_img.paste(img, (x, y))
new_img.save(img_path)

print(f"Resized successfully! Old: {width}x{height}, New canvas: {new_width}x{new_height}")
