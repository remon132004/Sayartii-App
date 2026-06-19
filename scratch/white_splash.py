from PIL import Image

def generate_white_splash_icon():
    # فتح اللوجو الأصلي
    img = Image.open('assets/images/App_Icon.png')
    
    # لو الصورة فيها خلفية غامقة، هنحاول نخليها شفافة أو نستخدم اللوجو بس
    # بما أننا عاوزينها "حلوة" على الأبيض، هنستخدم اللوجو نفسه
    width, height = img.size
    
    # تصغير اللوجو بنسبة 60% ليكون حجمه "حلو" وموسطن
    new_size = (int(width * 0.6), int(height * 0.6))
    logo_small = img.resize(new_size, Image.Resampling.LANCZOS)
    
    # إنشاء صورة شفافة تماماً
    canvas = Image.new('RGBA', (width, height), (0, 0, 0, 0))
    
    # وضع اللوجو في المنتصف
    offset = ((width - new_size[0]) // 2, (height - new_size[1]) // 2)
    canvas.paste(logo_small, offset, logo_small if logo_small.mode == 'RGBA' else None)
    
    canvas.save('assets/images/white_splash_foreground.png')
    print("White splash icon generated.")

if __name__ == "__main__":
    generate_white_splash_icon()
