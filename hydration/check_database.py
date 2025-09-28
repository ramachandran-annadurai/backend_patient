#!/usr/bin/env python3
"""
Check what data is stored in the SQLite database
"""
import sqlite3
import os
from datetime import datetime

def check_database():
    print("🔍 Checking SQLite Database Storage...")
    print("=" * 50)
    
    db_path = "vital_hydration.db"
    
    if not os.path.exists(db_path):
        print(f"❌ Database file '{db_path}' does not exist")
        return
    
    print(f"✅ Database file found: {db_path}")
    print(f"📁 File size: {os.path.getsize(db_path)} bytes")
    print(f"📅 Last modified: {datetime.fromtimestamp(os.path.getmtime(db_path))}")
    
    try:
        conn = sqlite3.connect(db_path)
        cursor = conn.cursor()
        
        # Get all tables
        cursor.execute("SELECT name FROM sqlite_master WHERE type='table';")
        tables = cursor.fetchall()
        
        print(f"\n📋 Tables in database:")
        for table in tables:
            print(f"   - {table[0]}")
        
        # Check if patients table exists
        if any('patients' in table[0] for table in tables):
            print(f"\n👥 Patients table data:")
            cursor.execute("SELECT COUNT(*) FROM patients")
            patient_count = cursor.fetchone()[0]
            print(f"   Total patients: {patient_count}")
            
            if patient_count > 0:
                cursor.execute("SELECT patient_id, name, daily_goal_ml, created_at FROM patients LIMIT 5")
                patients = cursor.fetchall()
                for patient in patients:
                    print(f"   - {patient[0]}: {patient[1]} (Goal: {patient[2]}ml, Created: {patient[3]})")
        
        # Check if patient_hydration_logs table exists
        if any('patient_hydration_logs' in table[0] for table in tables):
            print(f"\n💧 Patient Hydration Logs:")
            cursor.execute("SELECT COUNT(*) FROM patient_hydration_logs")
            log_count = cursor.fetchone()[0]
            print(f"   Total logs: {log_count}")
            
            if log_count > 0:
                cursor.execute("""
                    SELECT patient_id, amount_ml, drink_type, timestamp, notes 
                    FROM patient_hydration_logs 
                    ORDER BY timestamp DESC 
                    LIMIT 5
                """)
                logs = cursor.fetchall()
                for log in logs:
                    print(f"   - {log[0]}: {log[1]}ml {log[2]} at {log[3]} ({log[4] or 'No notes'})")
        
        # Check if hydration_logs table exists (user-based)
        if any('hydration_logs' in table[0] for table in tables):
            print(f"\n💧 User Hydration Logs:")
            cursor.execute("SELECT COUNT(*) FROM hydration_logs")
            log_count = cursor.fetchone()[0]
            print(f"   Total logs: {log_count}")
            
            if log_count > 0:
                cursor.execute("""
                    SELECT user_id, amount_ml, drink_type, timestamp, notes 
                    FROM hydration_logs 
                    ORDER BY timestamp DESC 
                    LIMIT 5
                """)
                logs = cursor.fetchall()
                for log in logs:
                    print(f"   - User {log[0]}: {log[1]}ml {log[2]} at {log[3]} ({log[4] or 'No notes'})")
        
        conn.close()
        
    except Exception as e:
        print(f"❌ Error reading database: {e}")

if __name__ == "__main__":
    check_database()
