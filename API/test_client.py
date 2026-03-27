import requests

url = "http://127.0.1:8000/ingest"
data = {
    "systeem": "Scanner-Unit-05",
    "informatie": "Boek-ID 98234 ingescand op locatie A"
}

response =requests.post(url, json=data)
print(f"Status Code: {response.status_code}")
print(f"Response: {response.json()}")