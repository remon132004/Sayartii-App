from PIL import Image, ImageDraw

def create_high_res_splash_icon():
    # 1. Load the original App Icon
    img = Image.open('assets/images/App_Icon.png').convert("RGBA")
    w, h = img.size

    # 2. We want a fixed 1152x1152 canvas (Android 12 standard)
    canvas_size = 1152
    
    # 3. We want the icon to be crisp. Let's make it 600x600 in the center
    # This is about 52% of the canvas, which provides plenty of padding
    target_icon_size = 600
    
    # 4. Apply high-quality rounded corner mask to the original image BEFORE resizing
    radius = int(w * 0.22)
    mask = Image.new('L', (w, h), 0)
    draw = ImageDraw.Draw(mask)
    draw.rounded_rectangle((0, 0, w, h), radius, fill=255)
    
    # Apply mask
    rounded_img = Image.new('RGBA', (w, h), (0, 0, 0, 0))
    rounded_img.paste(img, (0, 0), mask)

    # 5. Resize the rounded image to our target crisp size
    small_icon = rounded_img.resize((target_icon_size, target_icon_size), Image.Resampling.LANCZOS)

    # 6. Paste into the transparent canvas
    canvas = Image.new('RGBA', (canvas_size, canvas_size), (0, 0, 0, 0))
    offset = ((canvas_size - target_icon_size) // 2, (canvas_size - target_icon_size) // 2)
    canvas.paste(small_icon, offset, small_icon)

    # 7. Save it
    canvas.save('assets/images/perfect_splash_icon_hq.png')
    print("High-quality crisp splash icon created!")

if __name__ == "__main__":
    create_high_res_splash_icon()
