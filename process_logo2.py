import numpy as np
from PIL import Image
import colorsys

img_path = r'd:\flutter\sayartii\assets\icons\Sayartii.png'
out_path = r'd:\flutter\sayartii\assets\icons\Sayartii_processed.png'

# Target Color (Teal)
# #0D9488
tr, tg, tb = 13, 148, 136

img = Image.open(img_path).convert('RGBA')
arr = np.array(img)

# We want to extract the logo and cleanly apply the target color to the cyan parts.
# The original image has a white background.

for y in range(arr.shape[0]):
    for x in range(arr.shape[1]):
        r, g, b, a = arr[y, x]
        
        # If it's already transparent, skip
        if a == 0:
            continue
            
        h, s, v = colorsys.rgb_to_hsv(r/255.0, g/255.0, b/255.0)
        
        # We need to distinguish between:
        # 1. White background (high v, low s)
        # 2. Gray gear (medium/high v, very low s)
        # 3. Cyan logo (medium/high v, high s, hue ~0.5)
        
        if s > 0.15 and 0.4 < h < 0.7:
            # It's the cyan part.
            # The original image is on a white background, so anti-aliasing means
            # pixels near the edge are a mix of cyan and white (s gets lower, v gets higher).
            # To perfectly replace the color and remove the white background:
            
            # The alpha should be proportional to how much "color" there is versus white.
            # Pure white has v=1.0, s=0.0.
            # Pure cyan has v=~1.0, s=~1.0. (Actually cyan is usually V=1.0, S=1.0)
            
            # Let's just calculate how dark the pixel is compared to white.
            # The 'cyan' parts should be completely recolored to tr, tg, tb.
            # The alpha is based on the original pixel's darkness or saturation.
            # Since target color is darker than cyan, if we just swap RGB, it will look right.
            
            # We want to set the pixel to EXACTLY the target color.
            # And use its original 'distance from white' as the new alpha.
            # Max color difference from white (255,255,255).
            dist_from_white = 255 - max(r, g, b) # Not great for cyan since cyan has G=255, B=255.
            
            # Better: use saturation to blend.
            # Pure color = target color.
            # Edge color = mix of target color and white.
            
            # We will mix target color with white based on original saturation.
            # Then we make the white background transparent.
            
            # Actually, the simplest way is to convert the color to the target color
            # but keep the original brightness (v) scaled.
            # Target HSV:
            th, ts, tv = colorsys.rgb_to_hsv(tr/255.0, tg/255.0, tb/255.0)
            
            # We want the new color to be exactly target color where s is high.
            # Where s is lower (anti-aliasing), we want it to fade to white (or transparent).
            
            # Let's just set the pixel to Target Color, but adjust its Alpha!
            # If a pixel was (128, 255, 255) it was 50% cyan, 50% white.
            # If we set it to TargetColor with 50% Alpha, when drawn on a white background, it will look 50% TargetColor, 50% White!
            # What is the opacity of the original cyan?
            # Opacity = saturation! (Since it's mixed with white).
            # But wait, original cyan might not be 100% saturated.
            
            # Let's just use HSV conversion, but force the target's V and S.
            # We scale S and V based on the original pixel's S and V relative to pure cyan.
            
            # Assume pure cyan in original image is s_max, v_max.
            # We just force hue = th.
            # We force s = ts * (s / 1.0)  # scale saturation
            # We force v = tv + (1-s)*(1-tv) # as s drops (closer to white), v goes to 1.0 (white)
            
            new_s = ts * min(s / 0.8, 1.0) # Boost s a bit to ensure full color
            new_v = tv + (1 - new_s) * (1 - tv)
            
            nr, ng, nb = colorsys.hsv_to_rgb(th, new_s, new_v)
            
            arr[y, x, 0] = int(nr * 255)
            arr[y, x, 1] = int(ng * 255)
            arr[y, x, 2] = int(nb * 255)
            
            # Soft remove white background
            if np.mean([r, g, b]) > 240:
                alpha = int(255 * (255 - np.mean([r, g, b])) / 15.0)
                arr[y, x, 3] = max(0, min(255, alpha))
                
        else:
            # Gray gear or white background
            # Soft remove white background
            if r > 230 and g > 230 and b > 230:
                # Fade out
                avg = (int(r)+int(g)+int(b))/3
                alpha = int(255 * (255 - avg) / 25.0)
                arr[y, x, 3] = max(0, min(255, alpha))

new_img = Image.fromarray(arr, 'RGBA')

# Now scale with Lanczos
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
print("Done processing image with EXACT Teal color!")
