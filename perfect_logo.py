import numpy as np
from PIL import Image, ImageDraw, ImageFont
import urllib.request
import io
import arabic_reshaper
from bidi.algorithm import get_display

# 1. Use standard Windows Arial Bold font (supports Arabic)
font_path = r"C:\Windows\Fonts\arialbd.ttf"
font_size = 140 # Adjust for proportion
font = ImageFont.truetype(font_path, size=font_size)

# 2. Load original image
img_path = r'd:\flutter\sayartii\assets\icons\Sayartii.png'
out_path = r'd:\flutter\sayartii\assets\icons\Sayartii_processed.png'

img = Image.open(img_path).convert('RGB') # Use RGB, assume white background
arr = np.array(img).astype(float)

# 3. Recolor Cyan to Teal perfectly
# Target Teal #0D9488 (13, 148, 136)
C_new = np.array([13, 148, 136])
W = np.array([255, 255, 255])

# Find the exact cyan color in the image (lowest Red, highest Blue)
r, g, b = arr[:,:,0], arr[:,:,1], arr[:,:,2]
cyan_mask = (b > r + 30) & (g > r + 30)

if np.any(cyan_mask):
    # Get the "purest" cyan pixel
    purest_cyan_idx = np.argmin(r[cyan_mask])
    C_old_r = r[cyan_mask][purest_cyan_idx]
    C_old_g = g[cyan_mask][purest_cyan_idx]
    C_old_b = b[cyan_mask][purest_cyan_idx]
    C_old = np.array([C_old_r, C_old_g, C_old_b])
    
    # Apply the linear transformation to all cyan-ish pixels
    # beta is how much "cyan" is in the pixel (0 for white, 1 for pure cyan)
    beta = (W[0] - r) / max(1, (W[0] - C_old[0]))
    beta = np.clip(beta, 0, 1)
    
    # We only apply this to pixels that are actually cyan-ish
    # to avoid recoloring dark gray pixels
    apply_mask = cyan_mask & (beta > 0.05)
    
    # P' = P + beta * (C_new - C_old)
    diff = (C_new - C_old)
    arr[apply_mask, 0] += beta[apply_mask] * diff[0]
    arr[apply_mask, 1] += beta[apply_mask] * diff[1]
    arr[apply_mask, 2] += beta[apply_mask] * diff[2]

# Ensure values are within 0-255
arr = np.clip(arr, 0, 255).astype(np.uint8)
img_recolored = Image.fromarray(arr, 'RGB')

# 4. Add Arabic Text "سيارتي"
text = "سيارتي"
reshaped_text = arabic_reshaper.reshape(text)
bidi_text = get_display(reshaped_text)

# We need a new canvas to fit the text below the logo
orig_w, orig_h = img_recolored.size

# Let's crop the white space to center it properly
bg = Image.new('RGB', img_recolored.size, (255, 255, 255))
diff = Image.composite(img_recolored, bg, Image.new('L', img_recolored.size, 255))
bbox = Image.eval(img_recolored, lambda x: 255 - x).getbbox()

if bbox:
    left, upper, right, lower = bbox
    # Add some padding
    left, upper, right, lower = max(0, left-20), max(0, upper-20), min(orig_w, right+20), min(orig_h, lower+20)
    logo_cropped = img_recolored.crop((left, upper, right, lower))
else:
    logo_cropped = img_recolored

logo_w, logo_h = logo_cropped.size

# Calculate text size using getbbox() instead of getsize()
# Create a dummy draw object
dummy_draw = ImageDraw.Draw(Image.new('RGB', (1, 1)))
text_bbox = dummy_draw.textbbox((0, 0), bidi_text, font=font)
text_w = text_bbox[2] - text_bbox[0]
text_h = text_bbox[3] - text_bbox[1]

# New canvas size
padding = 100
spacing = 30
new_w = max(logo_w, text_w) + padding * 2
new_h = logo_h + spacing + text_h + padding * 2

# We want the splash to have the app's background color #F7F9FC
# so it blends perfectly!
app_bg = (247, 249, 252)

# Create final image with the app's background color
final_img = Image.new('RGB', (new_w, new_h), app_bg)

# Wait, if we paste the cropped logo (which has a WHITE background)
# onto the #F7F9FC background, we'll see a white box!
# We must replace the white background of the cropped logo with #F7F9FC
logo_arr = np.array(logo_cropped).astype(float)
# Linear shift from White to AppBG
# alpha_w is how "white" a pixel is
r_l, g_l, b_l = logo_arr[:,:,0], logo_arr[:,:,1], logo_arr[:,:,2]
# Using the average lightness as alpha_w
alpha_w = np.mean(logo_arr, axis=2) / 255.0
# Only shift pixels that are very close to white
shift_mask = alpha_w > 0.8
# Apply shift: P' = P + (AppBG - White) * alpha_w
# Actually, just shift all pixels slightly towards AppBG based on their whiteness
bg_diff = np.array(app_bg) - np.array([255, 255, 255])
logo_arr[:,:,0] += alpha_w * bg_diff[0]
logo_arr[:,:,1] += alpha_w * bg_diff[1]
logo_arr[:,:,2] += alpha_w * bg_diff[2]

logo_arr = np.clip(logo_arr, 0, 255).astype(np.uint8)
logo_cropped = Image.fromarray(logo_arr, 'RGB')

# Paste logo
logo_x = (new_w - logo_w) // 2
logo_y = padding
final_img.paste(logo_cropped, (logo_x, logo_y))

# Draw text
draw = ImageDraw.Draw(final_img)
text_x = (new_w - text_w) // 2
# Adjust text_y to account for font vertical offset
text_y = logo_y + logo_h + spacing - text_bbox[1]
# Draw with Teal color #0D9488
draw.text((text_x, text_y), bidi_text, font=font, fill=(13, 148, 136))

# Now we need to resize it using Lanczos so it's a good size for the splash
# The canvas is currently e.g. 1500x1200.
# Android expects a square icon, so let's make it a perfect square
max_dim = max(new_w, new_h)
square_canvas = Image.new('RGB', (max_dim, max_dim), app_bg)
square_x = (max_dim - new_w) // 2
square_y = (max_dim - new_h) // 2
square_canvas.paste(final_img, (square_x, square_y))

# Scale down slightly to ensure it's not too huge in the splash screen
# A scale factor of 1.2 or 1.3 relative to the canvas
# The best way is to pad the square canvas
final_padding = int(max_dim * 0.4)
final_size = max_dim + final_padding * 2
final_splash = Image.new('RGB', (final_size, final_size), app_bg)
final_splash.paste(square_canvas, (final_padding, final_padding))

# Resize down using high-quality Lanczos for optimal sharpness
try:
    resample_filter = Image.Resampling.LANCZOS
except AttributeError:
    resample_filter = Image.LANCZOS

# 1024x1024 is a good standard size
final_splash = final_splash.resize((1024, 1024), resample_filter)

final_splash.save(out_path, "PNG", optimize=True)
print("Perfect Photoshop-quality logo generated!")
