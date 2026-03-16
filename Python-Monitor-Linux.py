from flask import Flask, jsonify
import psutil
app = Flask(__name__)

@app.route("/")
def system_status():
    # CPU
    psutil.cpu_percent(interval=None)
    cpu = psutil.cpu_percent(interval=1)

    # RAM
    ram = psutil.virtual_memory()
    ram_used_gb = round(ram.used / (1024**3), 2)
    ram_total_gb = round(ram.total / (1024**3), 2)
    ram_percent = ram.percent

    # Disk
    disk = psutil.disk_usage('/')
    disk_used_gb = round(disk.used / (1024**3), 2)
    disk_total_gb = round(disk.total / (1024**3), 2)
    disk_percent = disk.percent

    # JSON response
    return jsonify({
        "cpu_load_percent": cpu,
        "ram":{
            "used_gb": ram_used_gb,
            "total_gb": ram_total_gb,
            "percent": ram_percent
        },
        "disk": {
            "used_gb": disk_used_gb,
            "total_gb": disk_total_gb,
            "percent": disk_percent
        }
    })

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
