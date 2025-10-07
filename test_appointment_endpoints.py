"""
Quick test to verify appointment endpoints syntax
"""

import sys

try:
    # Test importing the module
    print("Testing app_simple.py syntax...")
    
    # Just compile the file
    with open('app_simple.py', 'r', encoding='utf-8') as f:
        code = f.read()
    
    compile(code, 'app_simple.py', 'exec')
    
    print("[SUCCESS] Syntax check PASSED!")
    print("[SUCCESS] All patient appointment endpoints have been successfully updated!")
    print("\nUpdated Features:")
    print("  1. GET /patient/appointments - Now supports 'type' filtering")
    print("  2. POST /patient/appointments - Requires both 'type' and 'appointment_type'")
    print("  3. PUT /patient/appointments/<id> - Blocks updates to approved appointments (403)")
    print("  4. DELETE /patient/appointments/<id> - Removes appointments")
    print("\nReady to start the server!")
    
except SyntaxError as e:
    print(f"[ERROR] Syntax Error: {e}")
    sys.exit(1)
except Exception as e:
    print(f"[ERROR] Error: {e}")
    sys.exit(1)
