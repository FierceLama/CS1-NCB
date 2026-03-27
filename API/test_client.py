import requests

url = "http://127.0.0.1:8000/ingest"
data = {
    "systeem": "Scanner-Unit-05",
    "informatie": "Boek-ID 98234 ingescand op locatie A"
}

try:
    response = requests.post(url, json=data)
    print(f"Status Code: {response.status_code}")

    # Probeer de JSON te printen
    try:
        print(f"Response JSON: {response.json()}")
    except:
        print(f"Response Text: (geen JSON): {response.text}")

except Exception as e:
    print(f"Verbindingsfout: {e}")