#!/usr/bin/env python3
"""
Test email configuration
"""
import os
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from dotenv import load_dotenv

def test_email_config():
    """Test email configuration"""
    print("🔍 Testing Email Configuration...")
    
    # Load environment variables
    load_dotenv()
    
    sender_email = os.getenv("SENDER_EMAIL")
    sender_password = os.getenv("SENDER_PASSWORD")
    
    print(f"📧 SENDER_EMAIL: {'✅ Set' if sender_email else '❌ Missing'}")
    print(f"🔑 SENDER_PASSWORD: {'✅ Set' if sender_password else '❌ Missing'}")
    
    if not sender_email or not sender_password:
        print("\n❌ Email configuration missing!")
        print("💡 Please create a .env file with:")
        print("   SENDER_EMAIL=your_email@gmail.com")
        print("   SENDER_PASSWORD=your_app_password")
        return False
    
    # Test email sending
    try:
        print(f"\n📤 Testing email to: {sender_email}")
        
        msg = MIMEMultipart()
        msg['From'] = sender_email
        msg['To'] = sender_email
        msg['Subject'] = "Test Email - Patient Alert System"
        
        body = """
        This is a test email from Patient Alert System.
        
        If you receive this, your email configuration is working correctly!
        
        Best regards,
        Patient Alert System Team
        """
        
        msg.attach(MIMEText(body, 'plain'))
        
        print("🔗 Connecting to Gmail SMTP...")
        server = smtplib.SMTP('smtp.gmail.com', 587)
        server.starttls()
        
        print("🔐 Logging in to Gmail...")
        server.login(sender_email, sender_password)
        
        print("📤 Sending test email...")
        text = msg.as_string()
        server.sendmail(sender_email, sender_email, text)
        server.quit()
        
        print("✅ Test email sent successfully!")
        print("📬 Check your inbox for the test email")
        return True
        
    except smtplib.SMTPAuthenticationError as e:
        print(f"❌ Authentication failed: {e}")
        print("💡 Check your Gmail App Password - make sure 2FA is enabled")
        return False
    except Exception as e:
        print(f"❌ Email test failed: {e}")
        return False

if __name__ == "__main__":
    test_email_config()
