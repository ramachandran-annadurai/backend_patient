#!/usr/bin/env python3
"""
Test script to check app_simple.py syntax
"""

import ast
import sys

def check_syntax(filename):
    """Check if a Python file has valid syntax"""
    try:
        with open(filename, 'r', encoding='utf-8') as f:
            source = f.read()
        
        # Parse the AST
        ast.parse(source)
        print(f"✅ {filename} has valid syntax")
        return True
        
    except SyntaxError as e:
        print(f"❌ Syntax error in {filename}:")
        print(f"   Line {e.lineno}: {e.text}")
        print(f"   Error: {e.msg}")
        return False
        
    except Exception as e:
        print(f"❌ Error reading {filename}: {e}")
        return False

if __name__ == "__main__":
    if check_syntax("app_simple.py"):
        print("🎉 All syntax checks passed!")
        sys.exit(0)
    else:
        print("💥 Syntax errors found!")
        sys.exit(1)
