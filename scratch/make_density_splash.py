import os
from PIL import Image, ImageDraw

def create_density_splash_icons():
    # Load original image
    img = Image.open('assets/images/App_Icon.png').convert("RGBA")
    orig_w, orig_h = img.size

    # Densities for Android Splash Screen (based on 288dp)
    densities = {
        'drawable-mdpi': 288,
        'drawable-hdpi': 432,
        'drawable-xhdpi': 576,
        'drawable-xxhdpi': 864,
        'drawable-xxxhdpi': 1152,
        'drawable': 288 # fallback
    }

    base_path = 'android/app/src/main/res/'

    for folder, size in densities.items():
        # Mask original
        radius = int(orig_w * 0.22)
        mask = Image.new('L', (orig_w, orig_h), 0)
        draw = ImageDraw.Draw(mask)
        draw.rounded_rectangle((0, 0, orig_w, orig_h), radius, fill=255)
        
        rounded_img = Image.new('RGBA', (orig_w, orig_h), (0, 0, 0, 0))
        rounded_img.paste(img, (0, 0), mask)

        # Scale the actual icon to 50% of the canvas size to give it safe padding
        # 50% gives it a very nice, small, crisp look.
        target_icon_size = int(size * 0.52)
        small_icon = rounded_img.resize((target_icon_size, target_icon_size), Image.Resampling.LANCZOS)

        # Create transparent canvas for this density
        canvas = Image.new('RGBA', (size, size), (0, 0, 0, 0))
        offset = ((size - target_icon_size) // 2, (size - target_icon_size) // 2)
        canvas.paste(small_icon, offset, small_icon)

        # Save directly to the Android drawable folder
        out_dir = os.path.join(base_path, folder)
        if not os.path.exists(out_dir):
            os.makedirs(out_dir)
            
        out_path = os.path.join(out_dir, 'ic_splash.png')
        canvas.save(out_path, optimize=True)
        print(f"Generated {size}x{size} for {folder}")

if __name__ == "__main__":
    create_density_splash_icons()
