import requests

BASE_URL = "http://127.0.0.1:8000"

def test_succesvolle_ingest():
    print("Test 1: Succesvolle ingest uitvoeren...")
    data = {"systeem": "Scanner01", "informatie": "Boek geretourneerd"}
    response = requests.post(f"{BASE_URL}/ingest", json=data)
    print(f"Status Code: {response.status_code}, requests.Response: {response.json()}")
    assert response.status_code == 201

def test_foutive_invoer():
    print("\nTest 2: Foutieve invoer sturen (missende velden)...")
    data = {"naam": "Dit klopt niet"}
    response = requests.post(f"{BASE_URL}/ingest", json=data)
    print(f"Status: {response.status_code} (Verwacht: 422)")
    assert response.status_code == 422

if __name__ == "__main__":
    try:
        test_succesvolle_ingest()
        test_foutive_invoer()
        print("\nAlle tests zijn geslaagd!")
    except Exception as e:
        print(f"\nTest gefaald: {e}")