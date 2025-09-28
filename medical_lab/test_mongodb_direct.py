#!/usr/bin/env python3
"""
Test MongoDB directly
"""

import asyncio
import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from app.services.mongodb_service import mongodb_service

async def test_mongodb_direct():
    """Test MongoDB directly"""
    print("🔍 Testing MongoDB Directly...")
    
    try:
        print(f"MongoDB connected: {mongodb_service.is_connected()}")
        
        if mongodb_service.is_connected():
            # Get all documents for the patient
            patient_id = "arunkumar.loganathan.lm@gmail.com"
            print(f"🔍 Getting documents for patient: {patient_id}")
            
            # Use the collection directly to see raw data
            cursor = mongodb_service.collection.find({"patient_id": patient_id})
            count = 0
            async for doc in cursor:
                count += 1
                print(f"📄 Document {count}:")
                print(f"   - _id: {doc.get('_id')}")
                print(f"   - patient_id: {doc.get('patient_id')}")
                print(f"   - filename: {doc.get('filename')}")
                print(f"   - document_type: {doc.get('document_type')}")
                print(f"   - created_at: {doc.get('created_at')}")
                print(f"   - All keys: {list(doc.keys())}")
                
            print(f"✅ Found {count} documents in MongoDB")
        else:
            print("❌ MongoDB not connected")
            
    except Exception as e:
        print(f"❌ Error: {e}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    asyncio.run(test_mongodb_direct())
