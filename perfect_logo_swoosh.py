import numpy as np
from PIL import Image, ImageDraw, ImageFont
import urllib.request
import io
import arabic_reshaper
from bidi.algorithm import get_display

# 1. Download beautiful Arabic Calligraphy Font (Aref Ruqaa)
# 1. Use built-in Windows Arabic Font (Sakkal Majalla or Tahoma)
# These fonts natively support Arabic Presentation Forms required by Pillow!
font_path = r"C:\Windows\Fonts\majalla.ttf"
font_size = 280
try:
    font = ImageFont.truetype(font_path, size=font_size)
except IOError:
    font = ImageFont.truetype(r"C:\Windows\Fonts\tahoma.ttf", size=font_size)

# 2. Load original image
img_path = r'd:\flutter\sayartii\assets\icons\Sayartii.png'
out_path = r'd:\flutter\sayartii\assets\icons\Sayartii_processed.png'

img = Image.open(img_path).convert('RGB')
arr = np.array(img).astype(float)

# 3. Recolor Cyan to Teal perfectly
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

# 4. Crop Logo exactly
orig_w, orig_h = img_recolored.size
bbox = Image.eval(img_recolored, lambda x: 255 - x).getbbox()
if bbox:
    left, upper, right, lower = bbox
    logo_cropped = img_recolored.crop((left, upper, right, lower))
else:
    logo_cropped = img_recolored

# Ensure background of logo is transparent or perfectly matches app_bg
logo_arr = np.array(logo_cropped.convert('RGBA'))
alpha_w = np.mean(logo_arr[:,:,:3], axis=2) / 255.0
logo_arr[:,:,3] = np.clip((1 - alpha_w) * 255 * 1.5, 0, 255).astype(np.uint8) # Make white transparent
logo_cropped = Image.fromarray(logo_arr, 'RGBA')
logo_w, logo_h = logo_cropped.size

# 5. Render Arabic Text exactly
text = "سيارتي"
reshaped_text = arabic_reshaper.reshape(text)
bidi_text = get_display(reshaped_text)

# Render text on a large transparent canvas
text_canvas = Image.new('RGBA', (800, 400), (255, 255, 255, 0))
text_draw = ImageDraw.Draw(text_canvas)
text_draw.text((100, 100), bidi_text, font=font, fill=(13, 148, 136, 255))

# Crop text exactly
text_bbox = text_canvas.getbbox()
text_cropped = text_canvas.crop(text_bbox)
text_w, text_h = text_cropped.size

# 6. Composite them together
app_bg = (247, 249, 252)
padding = 150
# Force overlap to ensure they are close together
spacing = -100 
new_w = max(logo_w, text_w) + padding * 2
new_h = logo_h + spacing + text_h + padding * 2

final_img = Image.new('RGBA', (new_w, new_h), (247, 249, 252, 255))

logo_x = (new_w - logo_w) // 2
logo_y = padding
final_img.alpha_composite(logo_cropped, (logo_x, logo_y))

# The "S" in Sayartii is on the left. The "ي" in سيارتي is on the left.
# Let's align the text visually. Center it horizontally.
text_x = (new_w - text_w) // 2
text_y = logo_y + logo_h + spacing
final_img.alpha_composite(text_cropped, (text_x, text_y))

# 7. Draw custom swoosh/tail for the "ي"
# The "ي" is on the left side of the text_cropped.
draw = ImageDraw.Draw(final_img)
tail_start_x = text_x + 10 # Left edge of Arabic text
tail_start_y = text_y + text_h - 10 # Bottom left

# Draw a beautiful cubic bezier curve from the tail of "ي"
# sweeping down and right
import math
def draw_cubic_bezier(draw, p0, p1, p2, p3, fill, width):
    steps = 100
    pts = []
    for i in range(steps + 1):
        t = i / steps
        x = (1-t)**3 * p0[0] + 3*(1-t)**2 * t * p1[0] + 3*(1-t) * t**2 * p2[0] + t**3 * p3[0]
        y = (1-t)**3 * p0[1] + 3*(1-t)**2 * t * p1[1] + 3*(1-t) * t**2 * p2[1] + t**3 * p3[1]
        pts.append((x, y))
    draw.line(pts, fill=fill, width=width, joint="curve")

# Points for swoosh
p0 = (tail_start_x, tail_start_y)
p1 = (tail_start_x - 60, tail_start_y + 40)
p2 = (tail_start_x + text_w//2, tail_start_y + 60)
p3 = (text_x + text_w, tail_start_y + 20)

# Draw multiple bezier lines to simulate calligraphy brush thickness
for w in range(1, 8):
    offset = w - 4
    draw_cubic_bezier(draw, 
        (p0[0], p0[1]+offset), 
        (p1[0], p1[1]+offset*2), 
        (p2[0], p2[1]+offset*1.5), 
        (p3[0], p3[1]+offset), 
        fill=(13, 148, 136, 255), width=2)

# 8. Scale to fit Splash
max_dim = max(new_w, new_h)
square_canvas = Image.new('RGB', (max_dim, max_dim), app_bg)
square_canvas.paste(final_img, ((max_dim - new_w) // 2, (max_dim - new_h) // 2), final_img)

final_padding = int(max_dim * 0.15) # Very large logo
final_size = max_dim + final_padding * 2
final_splash = Image.new('RGB', (final_size, final_size), app_bg)
final_splash.paste(square_canvas, (final_padding, final_padding))

try:
    resample_filter = Image.Resampling.LANCZOS
except AttributeError:
    resample_filter = Image.LANCZOS

final_splash = final_splash.resize((1024, 1024), resample_filter)
final_splash.save(out_path, "PNG", optimize=True)
print("Perfect Custom Logo Generated with Swoosh!")
