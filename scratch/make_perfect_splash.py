from PIL import Image, ImageDraw

def create_perfect_splash_icon():
    # 1. Load the original App Icon (which the user loves)
    img = Image.open('assets/images/App_Icon.png').convert("RGBA")
    w, h = img.size

    # 2. Apply a rounded corner mask (like the phone launcher does)
    # Radius = 20% of width
    radius = int(w * 0.22)
    mask = Image.new('L', (w, h), 0)
    draw = ImageDraw.Draw(mask)
    draw.rounded_rectangle((0, 0, w, h), radius, fill=255)
    
    # Apply mask
    rounded_img = Image.new('RGBA', (w, h), (0, 0, 0, 0))
    rounded_img.paste(img, (0, 0), mask)

    # 3. Scale it down to 45% so it's small and never gets clipped by Android's circular splash mask
    canvas_size = max(w, h) * 2  # Make canvas 2x larger to give plenty of padding
    new_w = int(w * 0.45)
    new_h = int(h * 0.45)
    small_icon = rounded_img.resize((new_w, new_h), Image.Resampling.LANCZOS)

    # 4. Create a transparent canvas and paste the small rounded icon in the center
    canvas = Image.new('RGBA', (canvas_size, canvas_size), (0, 0, 0, 0))
    offset = ((canvas_size - new_w) // 2, (canvas_size - new_h) // 2)
    canvas.paste(small_icon, offset, small_icon)

    # 5. Save it
    canvas.save('assets/images/perfect_splash_icon.png')
    print("Perfect splash icon created with rounded corners and padding!")

if __name__ == "__main__":
    create_perfect_splash_icon()
