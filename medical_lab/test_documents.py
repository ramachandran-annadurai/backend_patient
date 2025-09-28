#!/usr/bin/env python3
import requests

response = requests.get('http://localhost:8000/api/v1/patients/arunkumar.loganathan.lm@gmail.com/documents?limit=5')
if response.status_code == 200:
    data = response.json()
    print('📋 Recent documents:')
    for i, doc in enumerate(data.get('documents', [])[:3]):
        print(f'{i+1}. {doc.get("filename")} - ID: {doc.get("id")}')
else:
    print(f'❌ Error: {response.status_code}')
