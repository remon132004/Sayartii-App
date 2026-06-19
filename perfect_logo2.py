import numpy as np
from PIL import Image, ImageDraw, ImageFont
import urllib.request
import io
import arabic_reshaper
from bidi.algorithm import get_display

# 1. Download beautiful Arabic Font (Amiri)
font_url = "https://raw.githubusercontent.com/google/fonts/main/ofl/amiri/Amiri-Bold.ttf"
try:
    req = urllib.request.Request(font_url, headers={'User-Agent': 'Mozilla/5.0'})
    font_bytes = urllib.request.urlopen(req).read()
    font_size = 180 # Make font slightly bigger relative to the logo
    font = ImageFont.truetype(io.BytesIO(font_bytes), size=font_size)
except Exception as e:
    print(f"Failed to download Amiri, falling back to Arial: {e}")
    font_size = 150
    font = ImageFont.truetype(r"C:\Windows\Fonts\arialbd.ttf", size=font_size)

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

# 4. Add Arabic Text "سيارتي"
text = "سيارتي"
reshaped_text = arabic_reshaper.reshape(text)
bidi_text = get_display(reshaped_text)

orig_w, orig_h = img_recolored.size
bg = Image.new('RGB', img_recolored.size, (255, 255, 255))
bbox = Image.eval(img_recolored, lambda x: 255 - x).getbbox()

if bbox:
    left, upper, right, lower = bbox
    left, upper, right, lower = max(0, left-20), max(0, upper-20), min(orig_w, right+20), min(orig_h, lower+20)
    logo_cropped = img_recolored.crop((left, upper, right, lower))
else:
    logo_cropped = img_recolored

logo_w, logo_h = logo_cropped.size

dummy_draw = ImageDraw.Draw(Image.new('RGB', (1, 1)))
text_bbox = dummy_draw.textbbox((0, 0), bidi_text, font=font)
text_w = text_bbox[2] - text_bbox[0]
text_h = text_bbox[3] - text_bbox[1]

# User requested even tighter spacing (they said 'horizontal distance', likely meaning the gap separating them)
padding = 100
spacing = -120 # Very tight negative spacing to make the text hug the English word
new_w = max(logo_w, text_w) + padding * 2
new_h = logo_h + spacing + text_h + padding * 2

app_bg = (247, 249, 252)
final_img = Image.new('RGB', (new_w, new_h), app_bg)

logo_arr = np.array(logo_cropped).astype(float)
alpha_w = np.mean(logo_arr, axis=2) / 255.0
bg_diff = np.array(app_bg) - np.array([255, 255, 255])
logo_arr[:,:,0] += alpha_w * bg_diff[0]
logo_arr[:,:,1] += alpha_w * bg_diff[1]
logo_arr[:,:,2] += alpha_w * bg_diff[2]

logo_arr = np.clip(logo_arr, 0, 255).astype(np.uint8)
logo_cropped = Image.fromarray(logo_arr, 'RGB')

logo_x = (new_w - logo_w) // 2
logo_y = padding
final_img.paste(logo_cropped, (logo_x, logo_y))

draw = ImageDraw.Draw(final_img)
text_x = (new_w - text_w) // 2
text_y = logo_y + logo_h + spacing - text_bbox[1]
draw.text((text_x, text_y), bidi_text, font=font, fill=(13, 148, 136))

# 5. Make the logo bigger overall
max_dim = max(new_w, new_h)
square_canvas = Image.new('RGB', (max_dim, max_dim), app_bg)
square_x = (max_dim - new_w) // 2
square_y = (max_dim - new_h) // 2
square_canvas.paste(final_img, (square_x, square_y))

# Previous padding was 40%, let's reduce it to 20% to make the logo look BIGGER
final_padding = int(max_dim * 0.2) 
final_size = max_dim + final_padding * 2
final_splash = Image.new('RGB', (final_size, final_size), app_bg)
final_splash.paste(square_canvas, (final_padding, final_padding))

try:
    resample_filter = Image.Resampling.LANCZOS
except AttributeError:
    resample_filter = Image.LANCZOS

final_splash = final_splash.resize((1024, 1024), resample_filter)
final_splash.save(out_path, "PNG", optimize=True)
print("Updated logo generated successfully!")
