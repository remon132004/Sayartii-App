import sys
import numpy as np
from PIL import Image
from PyQt5.QtGui import QGuiApplication, QImage, QPainter, QFont, QColor
from PyQt5.QtCore import Qt, QRect

out_path = r'd:\flutter\sayartii\assets\icons\Sayartii_processed.png'

# 1. Recolor the logo using Numpy
img_path = r'd:\flutter\sayartii\assets\icons\Sayartii.png'
img = Image.open(img_path).convert('RGB')
arr = np.array(img).astype(float)

C_new = np.array([13, 148, 136])
W = np.array([255, 255, 255])
r, g, b = arr[:,:,0], arr[:,:,1], arr[:,:,2]
cyan_mask = (b > r + 30) & (g > r + 30)

if np.any(cyan_mask):
    purest_cyan_idx = np.argmin(r[cyan_mask])
    C_old = np.array([r[cyan_mask][purest_cyan_idx], g[cyan_mask][purest_cyan_idx], b[cyan_mask][purest_cyan_idx]])
    beta = (W[0] - r) / max(1, (W[0] - C_old[0]))
    beta = np.clip(beta, 0, 1)
    apply_mask = cyan_mask & (beta > 0.05)
    diff = (C_new - C_old)
    arr[apply_mask, 0] += beta[apply_mask] * diff[0]
    arr[apply_mask, 1] += beta[apply_mask] * diff[1]
    arr[apply_mask, 2] += beta[apply_mask] * diff[2]

arr = np.clip(arr, 0, 255).astype(np.uint8)
img_recolored = Image.fromarray(arr, 'RGB')

# 2. Perfect Crop Logo (Remove all background padding)
# We find where pixels are NOT the background color
bg_color = np.array([255, 255, 255])
# Or maybe the bg is close to white
diff_to_white = np.abs(arr[:, :, 0].astype(int) - 255) + np.abs(arr[:, :, 1].astype(int) - 255) + np.abs(arr[:, :, 2].astype(int) - 255)
# non-white pixels are where the diff is large
non_white_mask = diff_to_white > 10

coords = np.argwhere(non_white_mask)
if len(coords) > 0:
    y_min, x_min = coords.min(axis=0)
    y_max, x_max = coords.max(axis=0)
    logo_cropped = img_recolored.crop((x_min, y_min, x_max, y_max))
else:
    logo_cropped = img_recolored

logo_arr = np.array(logo_cropped.convert('RGBA'))
alpha_w = np.mean(logo_arr[:,:,:3], axis=2) / 255.0
logo_arr[:,:,3] = np.clip((1 - alpha_w) * 255 * 1.5, 0, 255).astype(np.uint8)
logo_cropped = Image.fromarray(logo_arr, 'RGBA')
logo_w, logo_h = logo_cropped.size

# Save temporary cropped logo
temp_logo_path = 'temp_logo.png'
logo_cropped.save(temp_logo_path)

# 2. Use PyQt5 to render text flawlessly with native OpenType GSUB (Calligraphy)
app = QGuiApplication(sys.argv)

# Create a high-res image
canvas_w, canvas_h = 1000, 1000
image = QImage(canvas_w, canvas_h, QImage.Format_ARGB32_Premultiplied)
app_bg = QColor(247, 249, 252)
image.fill(app_bg)

painter = QPainter(image)
painter.setRenderHint(QPainter.Antialiasing)
painter.setRenderHint(QPainter.TextAntialiasing)

# Draw Logo
logo_qimg = QImage(temp_logo_path)
logo_x = (canvas_w - logo_w) // 2
logo_y = 250
painter.drawImage(logo_x, logo_y, logo_qimg)

# Set up beautiful Calligraphy Font (Aldhabi is extremely ornate Diwani, Arabic Typesetting is elegant Naskh)
# We will use "Aldhabi" for massive swooshes.
font = QFont("Aldhabi", 150)
# Check if Aldhabi exists, if not use Arabic Typesetting
from PyQt5.QtGui import QFontDatabase
db = QFontDatabase()
if "Aldhabi" not in db.families():
    font = QFont("Arabic Typesetting", 120)

painter.setFont(font)
painter.setPen(QColor(13, 148, 136)) # Teal

text = "سيارتي"
# We don't need reshaping! Qt handles OpenType perfectly!
# Calculate text bounding box
fm = painter.fontMetrics()
text_rect = fm.boundingRect(text)

# We want the text to overlap perfectly with the English text
# Use exact baseline coordinates to avoid unpredictable bounding boxes from Calligraphy fonts
text_x = (canvas_w - text_rect.width()) // 2
text_baseline_y = logo_y + logo_h + 120 # Baseline slightly below the logo to ensure the swoosh sweeps right under it

painter.drawText(text_x, text_baseline_y, text)

painter.end()

# The image is currently 1000x1000, but the logo+text takes up a lot of space.
# Android 12 splashes crop heavily in a circle. We MUST scale the image down and put it on a larger canvas with padding.
from PyQt5.QtGui import QTransform
final_size = 1500
final_image = QImage(final_size, final_size, QImage.Format_ARGB32_Premultiplied)
final_image.fill(app_bg)

final_painter = QPainter(final_image)
final_painter.setRenderHint(QPainter.SmoothPixmapTransform)

# Scale down the 1000x1000 image to ~600x600 so it fits perfectly in the center
scaled_width = 700
scaled_height = 700
scaled_image = image.scaled(scaled_width, scaled_height, Qt.KeepAspectRatio, Qt.SmoothTransformation)

# Draw in the center
center_x = (final_size - scaled_width) // 2
center_y = (final_size - scaled_height) // 2
final_painter.drawImage(center_x, center_y, scaled_image)
final_painter.end()

# Save final
final_image.save(out_path)
print("Perfect PyQt5 Calligraphy Logo Generated with Correct Padding!")
