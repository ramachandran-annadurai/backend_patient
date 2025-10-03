#!/usr/bin/env python3
"""
Create sample doctor data in doctor_v2 collection
"""

import pymongo
import os
from datetime import datetime
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

def create_sample_doctor():
    """Create sample doctor data"""
    
    print("👨‍⚕️ Creating Sample Doctor Data in doctor_v2 Collection")
    print("=" * 60)
    
    try:
        # Connect to MongoDB
        mongo_uri = os.getenv('MONGO_URI', 'mongodb://localhost:27017/')
        db_name = os.getenv('DB_NAME', 'patients_db')
        
        print(f"🔗 Connecting to MongoDB...")
        print(f"URI: {mongo_uri}")
        print(f"Database: {db_name}")
        
        client = pymongo.MongoClient(mongo_uri)
        db = client[db_name]
        doctor_v2_collection = db["doctor_v2"]
        
        # Sample doctor data
        sample_doctors = [
            {
                "doctor_id": "DOC123456",
                "name": "Dr. Sarah Johnson",
                "specialty": "Cardiology",
                "email": "sarah.johnson@hospital.com",
                "phone": "+1-555-0123",
                "location": "New York Medical Center",
                "experience": 8,
                "rating": 4.9,
                "bio": "Experienced cardiologist specializing in interventional procedures",
                "education": "MD from Harvard Medical School",
                "certifications": ["Board Certified Cardiologist", "Fellow of American College of Cardiology"],
                "languages": ["English", "Spanish"],
                "availability": "Monday-Friday 9AM-5PM",
                "profile_image": "https://example.com/doctor-sarah.jpg",
                "created_at": datetime.now(),
                "updated_at": datetime.now()
            },
            {
                "doctor_id": "DOC789012",
                "name": "Dr. Michael Chen",
                "specialty": "Neurology",
                "email": "michael.chen@hospital.com",
                "phone": "+1-555-0456",
                "location": "Los Angeles Medical Center",
                "experience": 12,
                "rating": 4.7,
                "bio": "Board-certified neurologist with expertise in movement disorders",
                "education": "MD from Stanford Medical School",
                "certifications": ["Board Certified Neurologist", "Fellow of American Academy of Neurology"],
                "languages": ["English", "Mandarin"],
                "availability": "Tuesday-Thursday 8AM-6PM",
                "profile_image": "https://example.com/doctor-michael.jpg",
                "created_at": datetime.now(),
                "updated_at": datetime.now()
            },
            {
                "doctor_id": "DOC345678",
                "name": "Dr. Emily Rodriguez",
                "specialty": "Pediatrics",
                "email": "emily.rodriguez@hospital.com",
                "phone": "+1-555-0789",
                "location": "Chicago Children's Hospital",
                "experience": 6,
                "rating": 4.8,
                "bio": "Pediatrician specializing in child development and preventive care",
                "education": "MD from Johns Hopkins Medical School",
                "certifications": ["Board Certified Pediatrician", "Fellow of American Academy of Pediatrics"],
                "languages": ["English", "Spanish", "French"],
                "availability": "Monday-Wednesday-Friday 8AM-4PM",
                "profile_image": "https://example.com/doctor-emily.jpg",
                "created_at": datetime.now(),
                "updated_at": datetime.now()
            }
        ]
        
        # Insert sample doctors
        print(f"📝 Inserting {len(sample_doctors)} sample doctors...")
        result = doctor_v2_collection.insert_many(sample_doctors)
        print(f"✅ Inserted {len(result.inserted_ids)} doctors successfully")
        
        # Verify insertion
        count = doctor_v2_collection.count_documents({})
        print(f"📊 Total doctors in collection: {count}")
        
        # Show sample document
        sample_doc = doctor_v2_collection.find_one()
        print(f"📋 Sample document fields: {list(sample_doc.keys())}")
        print(f"📋 Sample doctor_id: {sample_doc.get('doctor_id')}")
        
        print("\n🎉 Sample doctor data created successfully!")
        print("Now you can test the doctor profile endpoints with these IDs:")
        for doctor in sample_doctors:
            print(f"  - {doctor['doctor_id']}: {doctor['name']} ({doctor['specialty']})")
        
    except Exception as e:
        print(f"❌ Error creating sample doctor data: {str(e)}")
        print("\nTroubleshooting:")
        print("1. Check your MONGO_URI in .env file")
        print("2. Check your DB_NAME in .env file")
        print("3. Ensure MongoDB is accessible")
        print("4. Check database permissions")

if __name__ == "__main__":
    create_sample_doctor()
