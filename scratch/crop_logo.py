from PIL import Image

def generate_splash_foreground():
    # استخدام الأيقونة اللي عجبتك
    img = Image.open('assets/images/App_Icon.png')
    width, height = img.size
    
    # ترك مساحة 30% من كل جانب ليكون اللوجو صغيراً في المنتصف وغير مقصوص
    left = width * 0.15
    top = height * 0.15
    right = width * 0.85
    bottom = height * 0.85
    
    # سنقوم بإنشاء صورة شفافة ونضع اللوجو في منتصفها بحجم أصغر
    # هذه الطريقة أفضل من مجرد القص
    canvas = Image.new('RGBA', (width, height), (0, 0, 0, 0))
    
    # تصغير اللوجو بنسبة 50%
    new_size = (int(width * 0.5), int(height * 0.5))
    logo_small = img.resize(new_size, Image.Resampling.LANCZOS)
    
    # وضع اللوجو في المنتصف
    offset = ((width - new_size[0]) // 2, (height - new_size[1]) // 2)
    canvas.paste(logo_small, offset, logo_small if logo_small.mode == 'RGBA' else None)
    
    canvas.save('assets/images/splash_foreground.png')
    print("New splash_foreground.png generated with 50% size and plenty of padding.")

if __name__ == "__main__":
    generate_splash_foreground()
