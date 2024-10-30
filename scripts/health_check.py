#!/usr/bin/env python3
import os
import requests
from datetime import datetime

def send_health_check():
    url = os.environ.get('HEALTH_CHECK_URL')
    if not url:
        return
    
    try:
        response = requests.get(url)
        print(f"[{datetime.now()}] Health check sent to {url}: {response.status_code}")
    except Exception as e:
        print(f"[{datetime.now()}] Error sending health check: {str(e)}")

if __name__ == "__main__":
    send_health_check() 