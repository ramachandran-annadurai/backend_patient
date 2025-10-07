#!/usr/bin/env python3
"""
Verify that we have exactly 136 endpoints in our Postman collection
"""

import json

def verify_endpoint_count():
    """Verify the total endpoint count"""
    
    # Load the main collection
    with open("Patient_Alert_System_136_Endpoints/Complete_136_Endpoints_Postman_Collection.json", "r") as f:
        collection = json.load(f)
    
    total_endpoints = 0
    category_breakdown = []
    
    print("🔍 Verifying endpoint count...")
    print("=" * 50)
    
    for category in collection["item"]:
        category_name = category["name"]
        endpoint_count = len(category["item"])
        total_endpoints += endpoint_count
        category_breakdown.append(f"{category_name}: {endpoint_count} endpoints")
        print(f"✅ {category_name}: {endpoint_count} endpoints")
    
    print("=" * 50)
    print(f"📊 Total Endpoints: {total_endpoints}")
    
    if total_endpoints == 136:
        print("✅ SUCCESS: Exactly 136 endpoints found!")
    else:
        print(f"❌ ERROR: Expected 136 endpoints, found {total_endpoints}")
    
    print("\n📋 Category Breakdown:")
    for breakdown in category_breakdown:
        print(f"  - {breakdown}")
    
    return total_endpoints == 136

if __name__ == "__main__":
    success = verify_endpoint_count()
    exit(0 if success else 1)




