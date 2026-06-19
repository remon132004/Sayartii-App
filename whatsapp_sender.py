import time
import pywhatkit as kit
import datetime

# قائمة الأرقام التي تريد الإرسال إليها (يجب أن تتضمن رمز الدولة، مثلاً +20 لمصر)
phone_numbers = [
    "+201xxxxxxxxx1",
    "+201xxxxxxxxx2",
    "+201xxxxxxxxx3"
]

# الرسالة التي تريد إرسالها
message = "مرحباً، هذه رسالة تجريبية."

# وقت الانتظار بين كل رسالة (بالثواني) - 60 ثانية تعني دقيقة واحدة
delay_seconds = 60

print("بدء إرسال الرسائل...")

for index, number in enumerate(phone_numbers):
    try:
        # حساب الوقت الحالي زائد دقيقتين لضمان فتح واتساب ويب في الوقت المناسب
        # pywhatkit تحتاج إلى تحديد الوقت بالساعات والدقائق
        now = datetime.datetime.now()
        send_time = now + datetime.timedelta(minutes=1)
        
        print(f"[{index + 1}/{len(phone_numbers)}] جاري إرسال الرسالة إلى {number} في الساعة {send_time.hour}:{send_time.minute}...")
        
        # إرسال الرسالة
        # wait_time=15 (وقت الانتظار لفتح المتصفح)، tab_close=True (لإغلاق التبويب بعد الإرسال)، close_time=5 (بعد كم ثانية يغلق التبويب)
        kit.sendwhatmsg(number, message, send_time.hour, send_time.minute, wait_time=20, tab_close=True, close_time=5)
        
        print(f"تم الإرسال بنجاح إلى {number}.")
        
        # الانتظار لمدة دقيقة (أو الوقت المحدد) قبل إرسال الرسالة التالية لتجنب الحظر
        if index < len(phone_numbers) - 1: # لا ننتظر بعد آخر رسالة
            print(f"الانتظار لمدة {delay_seconds} ثانية قبل الرسالة التالية لتجنب الحظر...")
            time.sleep(delay_seconds)
            
    except Exception as e:
        print(f"حدث خطأ أثناء الإرسال إلى {number}: {str(e)}")

print("تم الانتهاء من إرسال جميع الرسائل.")
