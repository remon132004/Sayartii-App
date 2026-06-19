import numpy as np
from PIL import Image
import colorsys

img_path = r'd:\flutter\sayartii\assets\icons\Sayartii.png'
out_path = r'd:\flutter\sayartii\assets\icons\Sayartii_processed.png'

img = Image.open(img_path).convert('RGBA')
data = np.array(img)

# Target color: #0D9488 (R: 13, G: 148, B: 136)
target_r, target_g, target_b = 13, 148, 136
target_h, target_s, target_v = colorsys.rgb_to_hsv(target_r/255., target_g/255., target_b/255.)

# Process pixels
r, g, b, a = data[:,:,0], data[:,:,1], data[:,:,2], data[:,:,3]

# 1. Remove white background
# If pixel is very close to white (R>240, G>240, B>240), make it transparent.
# To make it smooth, we can use a soft threshold.
white_mask = (r > 235) & (g > 235) & (b > 235)

# 2. Change Cyan to Teal
# Cyan is roughly R<100, G>150, B>200. We can convert to HSV to be precise.
# But numpy operations are faster.
hsv_data = np.zeros((data.shape[0], data.shape[1], 3))

# Vectorized RGB to HSV
r_norm = r / 255.0
g_norm = g / 255.0
b_norm = b / 255.0
cmax = np.max([r_norm, g_norm, b_norm], axis=0)
cmin = np.min([r_norm, g_norm, b_norm], axis=0)
delta = cmax - cmin

# We will just iterate to be safe and accurate with HSV conversion and anti-aliasing
for y in range(data.shape[0]):
    for x in range(data.shape[1]):
        pr, pg, pb, pa = data[y, x]
        
        # Soft background removal
        if pr > 240 and pg > 240 and pb > 240:
            # Fade out alpha based on how white it is to avoid jagged edges
            # 255 -> alpha 0. 240 -> alpha 255.
            alpha_factor = (255 - max(pr, pg, pb)) / 15.0
            data[y, x, 3] = int(255 * alpha_factor)
            continue
            
        if pa == 0:
            continue
            
        h, s, v = colorsys.rgb_to_hsv(pr/255., pg/255., pb/255.)
        
        # Cyan hue is typically around 0.5 to 0.6
        if 0.45 < h < 0.65 and s > 0.2:
            # Change hue to target hue, keep v, maybe adjust s
            new_r, new_g, new_b = colorsys.hsv_to_rgb(target_h, s, v)
            data[y, x, 0] = int(new_r * 255)
            data[y, x, 1] = int(new_g * 255)
            data[y, x, 2] = int(new_b * 255)

new_img = Image.fromarray(data, 'RGBA')

# Now apply the Lanczos scaling to make it 30% smaller on a canvas of the same size
orig_width, orig_height = new_img.size
scale_factor = 1.3
new_logo_width = int(orig_width / scale_factor)
new_logo_height = int(orig_height / scale_factor)

try:
    resample_filter = Image.Resampling.LANCZOS
except AttributeError:
    resample_filter = Image.LANCZOS

resized_logo = new_img.resize((new_logo_width, new_logo_height), resample_filter)
final_canvas = Image.new('RGBA', (orig_width, orig_height), (0, 0, 0, 0))
px = (orig_width - new_logo_width) // 2
py = (orig_height - new_logo_height) // 2
final_canvas.paste(resized_logo, (px, py))

final_canvas.save(out_path, "PNG")
print("Done processing image!")
