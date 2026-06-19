from PIL import Image
import os
import shutil

img_path = r'd:\flutter\sayartii\assets\images\perfect_splash_icon_hq.png'
backup_path = r'd:\flutter\sayartii\assets\images\perfect_splash_icon_hq_backup.png'

# Restore from backup to ensure we are working with the original high-quality image
if os.path.exists(backup_path):
    shutil.copy2(backup_path, img_path)

img = Image.open(img_path)
img = img.convert("RGBA")

orig_width, orig_height = img.size

# We want the logo to look smaller, so we SHRINK the logo itself using high-quality LANCZOS,
# but we keep the CANVAS exactly the same size. This prevents the Dart image library from
# doing poor-quality extreme downscaling.

# Scale factor: 1.5 implies logo becomes 1/1.5 = 66% of its original size.
scale_factor = 1.5
new_logo_width = int(orig_width / scale_factor)
new_logo_height = int(orig_height / scale_factor)

# Resize logo with ultra-high quality anti-aliasing filter
# Note: In newer Pillow versions, Image.Resampling.LANCZOS is used, but Image.LANCZOS works in older too.
try:
    resample_filter = Image.Resampling.LANCZOS
except AttributeError:
    resample_filter = Image.LANCZOS

resized_logo = img.resize((new_logo_width, new_logo_height), resample_filter)

# Create a new transparent canvas of the ORIGINAL size
new_canvas = Image.new('RGBA', (orig_width, orig_height), (0, 0, 0, 0))

# Paste the high-quality smaller logo in the center
x = (orig_width - new_logo_width) // 2
y = (orig_height - new_logo_height) // 2
new_canvas.paste(resized_logo, (x, y))

# Save with maximum quality settings
new_canvas.save(img_path, "PNG", optimize=True)

print(f"Resized with LANCZOS successfully! Canvas: {orig_width}x{orig_height}, Logo inside: {new_logo_width}x{new_logo_height}")
