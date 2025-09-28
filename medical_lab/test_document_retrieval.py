#!/usr/bin/env python3
import requests

print("🔍 Testing document retrieval...")
response = requests.get('http://localhost:8000/api/v1/documents/doc_1758173203_9531?include_base64=true')
print(f'Status: {response.status_code}')

if response.status_code == 200:
    data = response.json()
    doc = data.get('document', {})
    print(f'Document: {doc.get("filename")}')
    print(f'Has base64: {bool(doc.get("base64_data"))}')
    print(f'Has text: {bool(doc.get("extracted_text"))}')
    print(f'Base64 length: {len(doc.get("base64_data", ""))}')
else:
    print(f'Error: {response.text}')
